import SwiftUI
import CocoaLumberjackSwift

struct FolderChooserRow: View {
    @State var model: VCSFolderResponse
    
    var body: some View {
        HStack {
            Text(model.name)
        }
    }
}

struct FolderChooserSub: View {
    @Binding var path: [FCRouteData]
    @Binding var rootRouteData: FCRouteData
    
    @State var showStorageChooser = false
    @State var showPagesChooser = false
    @State var showNewFolderAlert = false
    @State var selectedStorage: VCSStorageResponse?
    
    var routeData: FCRouteData
    @State var loadingFolder: Result<VCSFolderResponse, Error>?
    
    @Binding var result: Result<VCSFolderResponse, Error>?
    var dismissChooser: (() -> Void)
    
    func sortedByName(folders: [VCSFolderResponse]?) -> [VCSFolderResponse] {
        var result = folders ?? []
        result = result.sorted { $0.cellData.name.lowercased() < $1.cellData.name.lowercased() }
        return result
    }
    
    var body: some View {
        switch loadingFolder {
        case .success(let currentFolder):
            ScrollViewReader { value in
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        Button {
                            Task {
                                let result = await VCSStorageResponse.loadUserStorages()
                                switch result {
                                case .success(let storage):
                                    showStorageChooser = true
                                case .failure(let error):
                                    DDLogError("FolderChooserSub - switch loadingFolder - error: \(error)")
                                }
                            }
                        } label: {
                            Image(currentFolder.storageType.storageImageName)
                        }
                        .padding(.trailing, 8)
                        .confirmationDialog("", isPresented: $showStorageChooser) {
                            StorageChooserLoadingButtons(path: $path, rootRouteData: $rootRouteData, resultFolder: $loadingFolder, showStorageChooser: $showStorageChooser, showPagesChooser: $showPagesChooser, selectedStorage: $selectedStorage)
                        }
                        .confirmationDialog("", isPresented: $showPagesChooser) {
                            PagesLoadingButtons(path: $path, rootRouteData: $rootRouteData, resultFolder: $loadingFolder, selectedStorage: $selectedStorage, showPagesChooser: $showPagesChooser)
                        }
                        
                        Button(currentFolder.storageTypeDisplayString) {
                            path.removeAll()
                        }
                        
                        ForEach(path) { routeData in
                            Button("/" + routeData.breadcrumbsName) {
                                if let index = path.firstIndex(where: { $0.resourceURI == routeData.resourceURI }) {
                                    path.removeLast(path.count - 1 - index)
                                }
                            }
                            .id(routeData.resourceURI)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .onAppear {
                    value.scrollTo(path.last?.resourceURI)
                }
            }
            
            List {
                ForEach(currentFolder.subfolders.sorted(by: { $0.name.lowercased() < $1.name.lowercased() }), id: \.rID) { subfolder in
                    NavigationLink(value: FCRouteData(resourceURI: subfolder.resourceURI, breadcrumbsName: subfolder.name)) {
                        FolderChooserRow(model: subfolder)
                    }
                }
                .onDelete(perform: deleteFolder)
            }
            .navigationTitle(routeData.breadcrumbsName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if routeData == rootRouteData {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            dismissChooser()
                        } label: {
                            Text(FolderChooserSettings.closeButtonTitle.vcsLocalized)
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showNewFolderAlert = true
                    } label: {
                        Label(FolderChooserSettings.newFolderButtonTitle.vcsLocalized, image: FolderChooserSettings.newFolderButtonIcon)
                    }
                    .alertNewFolder(isPresented: $showNewFolderAlert, currentFolder: currentFolder, onSuccess: {
                        path.append(FCRouteData(folder: $0))
                        loadingFolder = nil
                    })
                    Button {
                        self.result = .success(currentFolder)
                        dismissChooser()
                    } label: {
                        Text(FolderChooserSettings.selectButtonTitle.vcsLocalized)
                    }
                }
            }
            .onChange(of: rootRouteData) { newValue in
                self.loadingFolder = newValue.folderResult
            }
        case .failure(let error):
            Text(error.localizedDescription)
            //            ErrorView(error: error, retryHandler: loadFolder)
        case nil:
            ProgressView().onAppear(perform: loadFolder)
        }
        
    }
    
    private func loadFolder() {
        guard routeData.resourceURI.isEmpty == false else {
            loadingFolder = .failure(VCSError.GenericException("resourceURI is nil"))
            return
        }
        
        APIClient.folderAsset(assetURI: routeData.resourceURI).execute { (result: Result<VCSFolderResponse, Error>) in
            loadingFolder = result
        }
    }
    
    func deleteFolder(at offsets: IndexSet) {
        let itemsToDelete = offsets.compactMap { (try? self.loadingFolder?.get().subfolders.sorted(by: { $0.name.lowercased() < $1.name.lowercased() }))?[$0] }
        itemsToDelete.forEach { (itemToDelete: VCSFolderResponse) in
            APIClient.deleteAsset(asset: itemToDelete).execute(onSuccess: { (res: VCSEmptyResponse) in
                //TODO: iiliev FC
//                FileActions.deleteLocally(asset: itemToDelete)
                let storage = VCSGenericRealmModelStorage<VCSFolderResponse.RealmModel>()
                storage.delete(item: itemToDelete)
                DDLogDebug("\(itemToDelete.name) - deleted")
                NotificationCenter.postNotification(name: FolderChooserSettings.updateLocalDataSourcesNotification, userInfo: ["file" : itemToDelete])
                try? self.loadingFolder?.get().removeFolder(itemToDelete)
            }, onFailure: {(error: Error) in
                DDLogError("\(itemToDelete.name) - deleted: \(error.localizedDescription)")
            })
        }
    }
}
