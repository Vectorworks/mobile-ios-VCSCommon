//
//  File.swift
//
//
//  Created by Veneta Todorova on 3.09.24.
//

import Foundation
import RealmSwift
import SwiftUI

class SharedWithMeViewModel: ObservableObject, FileLoadable {
    @Binding var route: FileChooserRouteData
    
    @Published var paginationState: PaginationState = .hasNextPage
    
    @Published var viewState: FileChooserViewState = .loading

    @Published var fileTypeFilter: FileTypeFilter
    
    var hasMorePages: [String: Bool] = [:]
    
    var nextPage: [String: Int] = [:]

    var sharedWithMe: Bool {
        true
    }

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
        sampleFiles: [SharedLink.RealmModel],
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
            let folderAsset = sampleFiles.first?.sharedAsset?.asset

            models.append(contentsOf: folderAsset?.folderAsset?.files.map {
                FileChooserModel(
                    resourceUri: $0.resourceURI,
                    resourceId: $0.resourceID,
                    flags: $0.entity.flags,
                    name: $0.name,
                    thumbnailUrl: $0.thumbnailURL,
                    lastDateModified: nil,
                    isAvailableOnDevice: $0.isAvailableOnDevice
                )
            } ?? [])
        }

        let result = models.matchesFilter(fileTypeFilter, isConnected: isConnected)
        
        updatePaginationWithLoadedFiles(models: result)
        
        return result
    }
}
