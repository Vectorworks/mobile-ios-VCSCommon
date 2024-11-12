import Foundation
import RealmSwift
import SwiftUI

class SharedWithMeViewModel: ObservableObject, FileLoadable {
    
    public static var linksPredicate: NSPredicate {
        var predicate = NSPredicate(format: "isSampleFiles == false AND owner == nil")
        if let ownerLogin = VCSUser.savedUser?.login {
            predicate = NSPredicate(format: "isSampleFiles == false AND owner.RealmID == %@", ownerLogin)
        }
        return predicate
    }
    
    @Binding var route: FileChooserRouteData
    
    @Published var paginationState: PaginationState = .hasNextPage
    
    @Published var viewState: FileChooserViewState = .loading
    
    @Published var fileTypeFilter: FileTypeFilter
    
    var hasMorePages: [String: Bool] = [:]
    
    var nextPage: [String: Int] = [:]
    
    var sharedWithMe: Bool = true
    
    var itemPickedCompletion: (FileChooserModel) -> Void
    
    var onDismiss: (() -> Void)
    
    init(
        fileTypeFilter: FileTypeFilter,
        route: Binding<FileChooserRouteData>,
        itemPickedCompletion: @escaping (FileChooserModel) -> Void,
        onDismiss: @escaping (() -> Void)
    ) {
        self.fileTypeFilter = fileTypeFilter
        self._route = route
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
        setupPagination()
    }
    
    func filterAndMapToModels(
        allSharedItems: Results<VCSSharedWithMeAsset.RealmModel>,
        sharedLinks: Results<SharedLink.RealmModel>,
        isGuest: Bool,
        isConnected: Bool
    ) -> [FileChooserModel] {
        var models: [FileChooserModel] = []
        
        allSharedItems.forEach {
            if $0.assetType == AssetType.file.rawValue {
                models.append(FileChooserModel(
                    resourceUri: $0.resourceURI,
                    resourceId: $0.RealmID,
                    flags: $0.entity.asset.flags,
                    name: $0.entity.name,
                    thumbnailUrl: $0.entity.thumbnailURL,
                    lastDateModified: $0.entity.lastModifiedString.toDate(),
                    isAvailableOnDevice: $0.entity.isAvailableOnDevice
                ))
            }
        }
        
        if isGuest {
            let sampleFilesLink = VCSServer.default.serverURLString.stringByAppendingPath(
                path: "/links/:samples/:metadata/")
            let predicate = NSPredicate(format: "RealmID = %@", sampleFilesLink)
            let cachedSampleFilesLink = SharedLink.realmStorage.getAll(predicate: predicate).first
            
            if let sampleFilesMainFolder = cachedSampleFilesLink?.sharedAsset?.asset as? VCSFolderResponse {
                models.append(contentsOf: getAllFiles(from: sampleFilesMainFolder))
            }
        }
        
        models.append(contentsOf: convertSharedLinksToFileChooserModels(sharedLinks: sharedLinks))

        return models.matchesFilter(fileTypeFilter, isConnected: isConnected)
    }
    
    func convertSharedLinksToFileChooserModels(sharedLinks: Results<SharedLink.RealmModel>) -> [FileChooserModel] {
        var results: [FileChooserModel] = []
        sharedLinks
            .forEach { link in
                if link.sharedAsset?.assetType == AssetType.file.rawValue {
                    let fileAsset = link.sharedAsset!.asset!.fileAsset
                    results.append(FileChooserModel(
                        resourceUri: fileAsset!.resourceURI,
                        resourceId: fileAsset!.resourceID,
                        flags: fileAsset!.entityFlat.flags,
                        name: fileAsset!.name,
                        thumbnailUrl: fileAsset!.thumbnailURL,
                        lastDateModified: fileAsset!.lastModified.toDate(),
                        isAvailableOnDevice: fileAsset?.isAvailableOnDevice == true
                    ))
                } else {
                    let folderAsset = link.sharedAsset!.asset!.folderAsset!.entity
                    results.append(contentsOf: getAllFiles(from: folderAsset))
                }
            }
        return results
    }
    
    func getAllFiles(from folder: VCSFolderResponse) -> [FileChooserModel] {
        var allFiles = folder.files
            .map {
                FileChooserModel(
                    resourceUri: $0.resourceURI,
                    resourceId: $0.resourceID,
                    flags: $0.flags,
                    name: $0.name,
                    thumbnailUrl: $0.thumbnailURL,
                    lastDateModified: nil,
                    isAvailableOnDevice: $0.isAvailableOnDevice
                )
            }
        
        for subfolder in folder.subfolders {
            allFiles.append(contentsOf: getAllFiles(from: subfolder))
        }
        
        return allFiles
        
    }
}
