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
    
    func loadFolder(resourceUri: String) {
        self.viewState = .loading
        
        APIClient.folderAsset(assetURI: resourceUri).execute { (result: Result<VCSFolderResponse, Error>) in
            switch result {
                
            case .success(let success):
                success.loadLocalFiles()
                VCSCache.addToCache(item: success)
                
                self.viewState = .loaded
                
                do {
                    let loadedFolderResponse = try result.get()
                    let folder = VCSFolderResponse.realmStorage.getModelById(id: loadedFolderResponse.rID)
                    self.populateViewWithData(loadedFolder: folder, isExternal: loadedFolderResponse.storageType.isExternal)
                } catch {
                    print("Error retrieving the value: \(error)")
                }
                
            case .failure(let error):
                self.viewState = .error(error.localizedDescription)
                break
            }
        }
    }
    
    private func calculateRoute(resourceUri: String, displayName: String, isExternal: Bool) -> FileChooserRouteData {
        let routeData = MyFilesRouteData(resourceURI: resourceUri, displayName: displayName)
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
            .filter { file in
                self.fileTypeFilter.extensions.map { filterExtension in
                    filterExtension.isInFileName(file.name)
                }.contains(true)
            }
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
            } ?? []
        
        self.models = fileModels + folderModels
    }
}
