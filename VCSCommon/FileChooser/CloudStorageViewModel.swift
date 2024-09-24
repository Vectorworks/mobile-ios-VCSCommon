//
//  File.swift
//
//
//  Created by Veneta Todorova on 26.07.24.
//

import Foundation

enum ViewState {
    case loading
    case error(String)
    case loaded
}

class CloudStorageViewModel: ObservableObject {
    @Published var viewState: ViewState = .loading
    
    @Published var models: [FileChooserModel] = []
    
    @Published var fileTypeFilter: FileTypeFilter
    
    init(fileTypeFilter: FileTypeFilter) {
        self.fileTypeFilter = fileTypeFilter
    }
    
    func loadFolder(route: FileChooserRouteData, isConnectionAvailable: Bool) {
        self.viewState = .loading
        
        if isConnectionAvailable {
            APIClient.folderAsset(assetURI: route.resourceUri).execute { (result: Result<VCSFolderResponse, Error>) in
                switch result {
                    
                case .success(let success):
                    success.loadLocalFiles()
                    VCSCache.addToCache(item: success)
                    
                    self.viewState = .loaded
                    
                    let folder = VCSFolderResponse.realmStorage.getModelById(id: success.rID)
                    self.populateViewWithData(loadedFolder: folder, isExternal: success.storageType.isExternal)
                    
                case .failure(let error):
                    self.viewState = .error(error.localizedDescription)
                    break
                }
            }
        } else {
            self.viewState = .loaded
        }
    }
    
    private func calculateRoute(resourceUri: String, displayName: String, isExternal: Bool) -> FileChooserRouteData {
        let routeData = MyFilesRouteData(resourceUri: resourceUri, displayName: displayName)
        let result: FileChooserRouteData
        if isExternal {
            result = FileChooserRouteData.externalStorage(routeData)
        } else {
            result = FileChooserRouteData.s3(routeData)
        }
        return result
    }
    
    private func populateViewWithData(loadedFolder: RealmFolder?, isExternal: Bool) {
        let folderModels : [FileChooserModel] = loadedFolder?.subfolders
            .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
            .map {
                FileChooserModel(
                    resourceUri: $0.resourceURI,
                    resourceId: nil,
                    flags: $0.flags?.entityFlat,
                    name: $0.name,
                    thumbnailUrl: nil,
                    isFolder: true,
                    route: calculateRoute(resourceUri: $0.resourceURI, displayName: $0.name, isExternal: isExternal)
                )
            } ?? []
        
        let fileModels : [FileChooserModel] = loadedFolder?.files
            .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
            .map {
                FileChooserModel(
                    resourceUri: $0.resourceURI,
                    resourceId: $0.resourceID,
                    flags: $0.flags?.entityFlat,
                    name: $0.name,
                    thumbnailUrl: $0.thumbnailURL,
                    isFolder: false,
                    route: nil
                )
            }
            .matchesFilter(fileTypeFilter) ?? []
        
        self.models = fileModels + folderModels
    }
}
