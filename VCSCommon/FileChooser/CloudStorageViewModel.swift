//
//  File.swift
//
//
//  Created by Veneta Todorova on 26.07.24.
//

import Foundation
import RealmSwift
import SwiftUI

class CloudStorageViewModel: ObservableObject, FileLoadable {
    @Binding var route: FileChooserRouteData
    
    @Published var paginationState: PaginationState = .hasNextPage
    
    @Published var viewState: FileChooserViewState = .loading
    
    @Published var fileTypeFilter: FileTypeFilter
    
    var hasMorePages: [String: Bool] = [:]
    
    var nextPage: [String: Int] = [:]
    
    var sharedWithMe: Bool {
        false
    }
    
    init(fileTypeFilter: FileTypeFilter, route: Binding<FileChooserRouteData>) {
        self.fileTypeFilter = fileTypeFilter
        self._route = route
        setupPagination()
    }
    
    func filterAndMapToModels(
        allFiles: Results<VCSFileResponse.RealmModel>,
        isConnected: Bool
    ) -> [FileChooserModel] {
        var models: [FileChooserModel] = []
        
        let currentStorageFiles = allFiles
            .filter { $0.storageType == self.route.storageType.rawValue }
            .map {
                FileChooserModel(
                    resourceUri: $0.resourceURI,
                    resourceId: $0.resourceID,
                    flags: $0.flags?.entityFlat,
                    name: $0.name,
                    thumbnailUrl: $0.thumbnailURL,
                    lastDateModified: $0.lastModified.toDate(),
                    isAvailableOnDevice: $0.isAvailableOnDevice
                )
            }
        
        models.append(contentsOf: currentStorageFiles)
        
        return models.matchesFilter(fileTypeFilter, isConnected: isConnected)
    }
}
