import SwiftUI
import CocoaLumberjackSwift

struct FileChooserRow: View {
    @State var model: Asset
    
    var body: some View {
        HStack {
            Text(model.name)
        }
    }
}

struct FileChooserSub: View {
    @Binding var path: [FCRouteData]
    @State var name = ""
    var resourceURI: String
    @State var showStorageChooser = false
    @State var showPagesChooser = false
    @State var selectedStorage: VCSStorageResponse?
    @Binding var filterExtensions: [VCSFileType]
    var itemPickedCompletion: ((VCSFileResponse) -> Void)?
    var dismissChooser: (() -> Void)
    
//    var routeData: FCRouteData
    @State var resultFolder: Result<VCSFolderResponse, Error>?
    
    @Binding var result: VCSFileResponse?
    
    func sortedByName(folders: [VCSFolderResponse]?) -> [VCSFolderResponse] {
        var result = folders ?? []
        result = result.sorted { $0.cellData.name.lowercased() < $1.cellData.name.lowercased() }
        return result
    }
    
    var body: some View {
        switch resultFolder {
        case .success(let currentFolder):
            ScrollViewReader { value in
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        Button {
                            APIClient.listStorage().execute(onSuccess: { (result: StorageList) in
                                VCSUser.savedUser?.setStorageList(storages: result)
                                showStorageChooser = true
                            }, onFailure: { (err: Error) in
                                print(err)
                            })
                        } label: {
                            Image(currentFolder.storageType.storageImageName)
                        }
                        .padding(.trailing, 8)
//                        .confirmationDialog("", isPresented: $showStorageChooser) {
//                            StorageChooserLoadingButtons(path: $path, rootRouteData: $rootRouteData, resultFolder: $resultFolder, showStorageChooser: $showStorageChooser, showPagesChooser: $showPagesChooser, selectedStorage: $selectedStorage)
//                        }
//                        .confirmationDialog("", isPresented: $showPagesChooser) {
//                            PagesLoadingButtons(path: $path, rootRouteData: $rootRouteData, resultFolder: $resultFolder, selectedStorage: $selectedStorage, showPagesChooser: $showPagesChooser)
//                        }
                        
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
                        FileChooserRow(model: subfolder)
                    }
                }
                .onDelete(perform: deleteFolder)
                
                let files = currentFolder.files.sorted(by: { $0.name.lowercased() < $1.name.lowercased() }).filter { file in
                    filterExtensions.map { filterExtension in
                        filterExtension.isInFile(file: file)
                    }.contains(true)
                }
                ForEach(files, id: \.rID) { file in
                    Button {
                        print("FileChooser item: \(file.name)")
                        dismissChooser()
                        itemPickedCompletion?(file)
                    } label: {
                        FileChooserRow(model: file)
                    }
                }
                .onDelete(perform: deleteFile)
            }
            .navigationTitle(name)
            .navigationBarTitleDisplayMode(.inline)
//            .onChange(of: rootRouteData) { newValue in
//                self.resultFolder = newValue.folderResult
//            }
        case .failure(let error):
            Text(error.localizedDescription)
            //            ErrorView(error: error, retryHandler: loadFolder)
        case nil:
            ProgressView()
                .onAppear(perform: loadFolder)
        }
        
    }
    
    private func loadFolder() {
        guard resourceURI.isEmpty == false else {
            resultFolder = .failure(VCSError.GenericException("resourceURI is nil"))
            return
        }
        
        APIClient.folderAsset(assetURI: resourceURI).execute { (result: Result<VCSFolderResponse, Error>) in
            switch result {
            case .success(let success):
                success.loadLocalFiles()
                VCSCache.addToCache(item: success)
            case .failure(_):
                break
            }
            resultFolder = result
        }
    }
    
    func deleteFolder(at offsets: IndexSet) {
        let itemsToDelete = offsets.compactMap { (try? self.resultFolder?.get().subfolders.sorted(by: { $0.name.lowercased() < $1.name.lowercased() }))?[$0] }
        itemsToDelete.forEach { (itemToDelete: VCSFolderResponse) in
            APIClient.deleteAsset(asset: itemToDelete).execute(onSuccess: { (res: VCSEmptyResponse) in
                //TODO: iiliev FC
//                FileActions.deleteLocally(asset: itemToDelete)
                let storage = VCSGenericRealmModelStorage<VCSFolderResponse.RealmModel>()
                storage.delete(item: itemToDelete)
                DDLogDebug("\(itemToDelete.name) - deleted")
                NotificationCenter.postNotification(name: FolderChooserSettings.updateLocalDataSourcesNotification, userInfo: ["file" : itemToDelete])
                try? self.resultFolder?.get().removeFolder(itemToDelete)
            }, onFailure: {(error: Error) in
                DDLogError("\(itemToDelete.name) - deleted: \(error.localizedDescription)")
            })
        }
    }
    
    func deleteFile(at offsets: IndexSet) {
        let itemsToDelete = offsets.compactMap { (try? self.resultFolder?.get().files.sorted(by: { $0.name.lowercased() < $1.name.lowercased() }))?[$0] }
        itemsToDelete.forEach { (itemToDelete: VCSFileResponse) in
            APIClient.deleteAsset(asset: itemToDelete).execute(onSuccess: { (res: VCSEmptyResponse) in
                //TODO: iiliev FC
//                FileActions.deleteLocally(asset: itemToDelete)
                
                itemToDelete.deleteFromCache()
                DDLogDebug("\(itemToDelete.name) - deleted")
                NotificationCenter.postNotification(name: FolderChooserSettings.updateLocalDataSourcesNotification, userInfo: ["file" : itemToDelete])
                try? self.resultFolder?.get().removeFile(itemToDelete)
            }, onFailure: {(error: Error) in
                DDLogError("\(itemToDelete.name) - deleted: \(error.localizedDescription)")
            })
        }
    }
}
