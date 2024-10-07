//
//  File.swift
//
//
//  Created by Veneta Todorova on 26.07.24.
//

import Foundation
import RealmSwift

enum ViewState: Equatable {
    case loading
    case error(String)
    case loaded
    case offline
}

class CloudStorageViewModel: ObservableObject {
    @Published var viewState: ViewState = .loading
    
    @Published var fileTypeFilter: FileTypeFilter
    
    @Published var currentRoute: FileChooserRouteData
    
    init(fileTypeFilter: FileTypeFilter, currentRoute: FileChooserRouteData) {
        self.fileTypeFilter = fileTypeFilter
        self.currentRoute = currentRoute
    }
    
    func loadFolder() {
        self.viewState = .loading
        
        APIClient.folderAsset(assetURI: currentRoute.resourceUri).execute { (result: Result<VCSFolderResponse, Error>) in
            switch result {
                
            case .success(let success):
                success.loadLocalFiles()
                VCSCache.addToCache(item: success)
                self.viewState = .loaded
                
            case .failure(let error):
                if error.responseCode == VCSNetworkErrorCode.noInternet.rawValue {
                    self.viewState = .offline
                } else {
                    self.viewState = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func mapToModels(
        currentFolderResults: Results<VCSFolderResponse.RealmModel>
    ) -> [FileChooserModel] {
        let currentFolder = currentFolderResults.filter("resourceURI == %@", currentRoute.resourceUri).first
        
        let folderModels: [FileChooserModel] = currentFolder?.subfolders
            .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
            .map(mapFolderToModel) ?? []
        
        let fileModels: [FileChooserModel] = currentFolder?.files
            .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
            .map {
                FileChooserModel(
                    resourceUri: $0.resourceURI,
                    resourceId: $0.resourceID,
                    flags: $0.flags?.entityFlat,
                    name: $0.name,
                    thumbnailUrl: $0.thumbnailURL,
                    isFolder: false,
                    route: nil,
                    lastDateModified: $0.lastModified.toDate(),
                    isAvailableOnDevice: $0.isAvailableOnDevice
                )
            }
            .matchesFilter(fileTypeFilter, isOffline: viewState == .offline) ?? []
        
        return fileModels + folderModels
    }
    
    private func mapFolderToModel(folderModel: VCSFolderResponse.RealmModel) -> FileChooserModel {
        let isExternal: Bool
        switch currentRoute {
        case .externalStorage:
            isExternal = true
        default:
            isExternal = false
        }
        
        let route = calculateRoute(
            resourceUri: folderModel.resourceURI,
            displayName: folderModel.name,
            isExternal: isExternal
        )
        
        return FileChooserModel(
            resourceUri: folderModel.resourceURI,
            resourceId: nil,
            flags: folderModel.flags?.entityFlat,
            name: folderModel.name,
            thumbnailUrl: nil,
            isFolder: true,
            route: route,
            lastDateModified: nil,
            isAvailableOnDevice: true
        )
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
}
