//
//  File.swift
//
//
//  Created by Veneta Todorova on 3.09.24.
//

import Foundation


class SharedWithMeViewModel: ObservableObject {
    static var rootSharedWithMePredicate: NSPredicate {
        NSPredicate(format: "sharedParentFolder = %@ AND sharedWithLogin == %@", "", VCSUser.savedUser?.login ?? "nil")
    }
    
    static var linksPredicate: NSPredicate {
        var predicate = NSPredicate(format: "isSampleFiles == false AND owner == nil")
        if let ownerLogin = VCSUser.savedUser?.login {
            predicate = NSPredicate(format: "isSampleFiles == false AND owner.RealmID == %@", ownerLogin)
        }
        return predicate
    }
    
    static var sampleLinkPredicate: NSPredicate {
        var predicate = NSPredicate(format: "isSampleFiles == true AND owner == nil")
        if let ownerLogin = VCSUser.savedUser?.login {
            predicate = NSPredicate(format: "isSampleFiles == true AND owner.RealmID == %@", ownerLogin)
        }
        return predicate
    }
    
    @Published var viewState: ViewState = .loading
    
    @Published var sortedFolders: [RealmFolder] = []
    
    @Published var sortedFiles: [RealmFile] = []
    
    @Published var models: [FileChooserModel] = []
    
    @Published var fileTypeFilter: FileTypeFilter
    
    @Published var currentRoute: FileChooserRouteData
    
    var itemPickedCompletion: ((FileChooserModel) -> Void)?
    
    var onDismiss: (() -> Void)
    
    var isInRoot: Bool {
        switch currentRoute {
        case .sharedWithMeRoot:
            true
            
        default:
            false
        }
    }
    
    init(
        fileTypeFilter: FileTypeFilter,
        currentRoute: FileChooserRouteData,
        itemPickedCompletion: ((FileChooserModel) -> Void)?,
        onDismiss: @escaping (() -> Void)) {
            self.fileTypeFilter = fileTypeFilter
            self.currentRoute = currentRoute
            self.itemPickedCompletion = itemPickedCompletion
            self.onDismiss = onDismiss
        }
    
    func calculateRoute(resourceUri: String, displayName: String) -> FileChooserRouteData {
        return FileChooserRouteData.sharedWithMe(SharedWithMeRouteData(resourceUri: resourceUri, displayName: displayName))
    }
    
    func mapToModels(sharedItems: [VCSSharedWithMeAsset]) -> [FileChooserModel] {
        let models: [FileChooserModel]
        
        switch currentRoute {
            
        case .sharedWithMeRoot :
            models = sharedItems.compactMap {
                FileChooserModel(
                    resourceUri: $0.resourceURI,
                    resourceId: nil,
                    flags: $0.asset.flags,
                    name: $0.name,
                    thumbnailUrl: $0.thumbnailURL,
                    isFolder: $0.isFolder,
                    route: calculateRoute(resourceUri: $0.resourceURI, displayName: $0.name))
            }
            
        case .sharedWithMe(_) :
            models = self.models
            
        case .s3(_), .externalStorage(_):
            models = []
        }
        
        return models
    }
    
    func loadFolder(resourceUri: String?) {
        self.viewState = .loading
        
        if let unwrappedResourceUri = resourceUri {
            APIClient.sharedWithMeAsset(assetURI: unwrappedResourceUri, related: true).execute { (result: Result<VCSSharedWithMeAsset, Error>) in
                switch result {
                case .success(let success):
                    VCSCache.addToCache(item: success)
                    success.asset.loadLocalFiles()
                    
                    self.viewState = .loaded
                    
                    do {
                        let folder = try VCSFolderResponse.realmStorage.getModelById(id: result.get().rID)
                        self.populateViewWithData(loadedFolder: folder)
                    } catch {
                        print("Error retrieving the value: \(error)")
                    }
                case .failure(let error):
                    self.viewState = .error(error.localizedDescription)
                }
            }
        } else {
            APIClient.listSharedWithMe().execute(completion: { (result: Result<VCSSharedWithMeResponse, Error>) in
                switch result {
                case .success(let success):
                    let cachedSharedWithMeItems = VCSSharedWithMeAsset.realmStorage.getAll(predicate: SharedWithMeViewModel.rootSharedWithMePredicate)
                    let itemsToRemove = cachedSharedWithMeItems
                        .filter { oldItem in
                            let isNotOnServer = success.results.allSatisfy { newItem in
                                newItem?.asset.rID != oldItem.asset.rID
                            }
                            return isNotOnServer
                        }
                    itemsToRemove.forEach { $0.deleteFromCache() }
                    success.results.forEach {
                        if let item = $0 { item.asset.loadLocalFiles()
                            VCSCache.addToCache(item: item, skipRootFolderID: true)
                        }
                    }
                    self.viewState = .loaded
                case .failure(let error):
                    self.viewState = .error(error.localizedDescription)
                }
            })
        }
    }
    
    private func populateViewWithData(loadedFolder: VCSFolderResponse.RealmModel?) {
        let files = loadedFolder?.files.map {
            FileChooserModel(
                resourceUri: $0.resourceURI,
                resourceId: $0.resourceID,
                flags: $0.flags?.entityFlat,
                name: $0.name,
                thumbnailUrl: $0.thumbnailURL,
                isFolder: false,
                route: nil)
        } ?? []
        
        let folders = loadedFolder?.subfolders.map {
            FileChooserModel(
                resourceUri: $0.resourceURI,
                resourceId: nil,
                flags: $0.flags?.entityFlat,
                name: $0.name,
                thumbnailUrl: nil,
                isFolder: true,
                route: self.calculateRoute(resourceUri: $0.resourceURI, displayName: $0.name))
        } ?? []
        
        self.models = folders + files
    }
}
