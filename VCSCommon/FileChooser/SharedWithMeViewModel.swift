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
    
    private var sampleFilesLink: String { return VCSServer.default.serverURLString.stringByAppendingPath(path: "/links/:samples/:metadata/") }
    
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
    
    func calculateRoute(resourceUri: String, displayName: String, isSharedLink: Bool) -> FileChooserRouteData {
        let routeData = MyFilesRouteData(resourceUri: resourceUri, displayName: displayName)
        if isSharedLink {
            return FileChooserRouteData.sharedLink(routeData)
        } else {
            return FileChooserRouteData.sharedWithMe(routeData)
        }
    }
    
    func mapToModels(
        sharedItems: [VCSSharedWithMeAsset],
        sampleFiles: [VCSShareableLinkResponse],
        sharedLinks: [VCSShareableLinkResponse],
        isGuest: Bool
    ) -> [FileChooserModel] {
        let models: [FileChooserModel]
        
        switch currentRoute {
            
        case .sharedWithMeRoot:
            let sharedItems = sharedItems
                .compactMap {
                    FileChooserModel(
                        resourceUri: $0.resourceURI,
                        resourceId: nil,
                        flags: $0.asset.flags,
                        name: $0.name,
                        thumbnailUrl: $0.thumbnailURL,
                        isFolder: $0.isFolder,
                        route: calculateRoute(resourceUri: $0.resourceURI, displayName: $0.name, isSharedLink: false),
                        lastDateModified: $0.isFolder ? nil : $0.lastModifiedString.toDate()
                    )
                }
            
            let sharedLinksModels = (sampleFiles + sharedLinks)
                .map { sharedFile in
                    let route: FileChooserRouteData?
                    if sharedFile.assetType == .folder {
                        route = calculateRoute(resourceUri: sharedFile.resourceURI, displayName: sharedFile.asset.name, isSharedLink: true)
                    } else {
                        route = nil
                    }
                    return FileChooserModel(
                        resourceUri: sharedFile.resourceURI,
                        resourceId: sharedFile.asset.resourceID,
                        flags: sharedFile.asset.flags,
                        name: sharedFile.asset.name,
                        thumbnailUrl: sharedFile.cellFileData?.thumbnailURL,
                        isFolder: sharedFile.assetType == .folder,
                        route: route,
                        lastDateModified: nil
                    )
                }
            
            models = sharedLinksModels + sharedItems
            
        case .sharedWithMe, .sharedLink:
            models = self.models
            
        case .s3, .externalStorage:
            models = []
        }
        
        return models
            .matchesFilter(fileTypeFilter)
    }
    
    func loadFolder(route: FileChooserRouteData, isGuest: Bool) {
        self.viewState = .loading
        
        switch route {
        case .sharedWithMeRoot:
            loadSharedWithMeRoot(isGuest: isGuest)
            
        case .sharedWithMe(let data):
            loadSharedWithMeFolder(resourceUri: data.resourceUri)
            
        case .sharedLink(let data):
            loadSharedLink(resourceUri: data.resourceUri)
            
        default:
            fatalError("Incorrect route in Shared with me.")
        }
    }
    
    private func loadSharedWithMeRoot(isGuest: Bool) {
        if isGuest {
            loadSampleFiles()
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
    
    private func loadSharedWithMeFolder(resourceUri: String) {
        APIClient.sharedWithMeAsset(assetURI: resourceUri, related: true).execute { (result: Result<VCSSharedWithMeAsset, Error>) in
            switch result {
            case .success(let success):
                VCSCache.addToCache(item: success)
                success.asset.loadLocalFiles()
                
                self.viewState = .loaded
                
                let folder = VCSFolderResponse.realmStorage.getModelById(id: success.asset.rID)
                self.populateViewWithData(loadedFolder: folder, isSharedLink: false)
                
            case .failure(let error):
                self.viewState = .error(error.localizedDescription)
            }
        }
    }
    
    private func loadSampleFiles() {
        let predicate = NSPredicate(format: "RealmID = %@", sampleFilesLink)
        let cachedSampleFilesLink = SharedLink.realmStorage.getAll(predicate: predicate).first
        
        let owner = VCSUser.savedUser
        let sampleFilesLink = SharedLink(link: sampleFilesLink, isSampleFiles: true, sharedAsset: cachedSampleFilesLink?.sharedAsset, owner: owner)
        VCSCache.addToCache(item: sampleFilesLink, forceNilValuesUpdate: true)
        guard let folderURI = sampleFilesLink.metadataURLSuffixForRequest else {
            self.viewState = .error("Error parsing sample files link \(sampleFilesLink.link)")
            return
        }
        
        APIClient.linkSharedAsset(assetURI: folderURI).execute(completion: { (result: Result<VCSShareableLinkResponse, Error>) in
            switch result {
            case .success(let success):
                success.asset.loadLocalFiles()
                let updatedSampleFilesLink = SharedLink(link: self.sampleFilesLink, isSampleFiles: true, sharedAsset: success, owner: owner)
                VCSCache.addToCache(item: updatedSampleFilesLink, forceNilValuesUpdate: true)
                self.viewState = .loaded
            case .failure(let error):
                self.viewState = .error(error.localizedDescription)
            }
        })
    }
    
    private func loadSharedLink(resourceUri: String) {
        APIClient.linkSharedAsset(assetURI: resourceUri).execute(completion: { (result: Result<VCSShareableLinkResponse, Error>) in
            switch result {
            case .success(let success):
                success.asset.loadLocalFiles()
                VCSCache.addToCache(item: success)
                
                self.viewState = .loaded
                
                let folder = VCSFolderResponse.realmStorage.getModelById(id: success.asset.rID)
                self.populateViewWithData(loadedFolder: folder, isSharedLink: true)
            case .failure(let error):
                self.viewState = .error(error.localizedDescription)
            }
        })
    }
    
    private func populateViewWithData(loadedFolder: VCSFolderResponse.RealmModel?, isSharedLink: Bool) {
        let files = loadedFolder?.files.map {
            FileChooserModel(
                resourceUri: $0.resourceURI,
                resourceId: $0.resourceID,
                flags: $0.flags?.entityFlat,
                name: $0.name,
                thumbnailUrl: $0.thumbnailURL,
                isFolder: false,
                route: nil,
                lastDateModified: nil
            )
        } ?? []
        
        let folders = loadedFolder?.subfolders.map {
            FileChooserModel(
                resourceUri: $0.resourceURI,
                resourceId: nil,
                flags: $0.flags?.entityFlat,
                name: $0.name,
                thumbnailUrl: nil,
                isFolder: true,
                route: self.calculateRoute(resourceUri: $0.resourceURI, displayName: $0.name, isSharedLink: isSharedLink),
                lastDateModified: nil
            )
        } ?? []
        
        self.models = folders + files
    }
}
