//
//  File.swift
//
//
//  Created by Veneta Todorova on 3.09.24.
//

import Foundation
import RealmSwift

class SharedWithMeViewModel: ObservableObject, FileLoadable {    
    var sharedWithMe: Bool {
        true
    }

    @Published var viewState: ViewState = .loading

    @Published var fileTypeFilter: FileTypeFilter

    var itemPickedCompletion: ((FileChooserModel) -> Void)?

    var onDismiss: (() -> Void)

    init(
        fileTypeFilter: FileTypeFilter,
        itemPickedCompletion: ((FileChooserModel) -> Void)?,
        onDismiss: @escaping (() -> Void)
    ) {
        self.fileTypeFilter = fileTypeFilter
        self.itemPickedCompletion = itemPickedCompletion
        self.onDismiss = onDismiss
    }

    func filterAndMapToModels(
        allSharedItems: Results<VCSSharedWithMeAsset.RealmModel>,
        sampleFiles: [SharedLink.RealmModel],
        isGuest: Bool
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

        return models.matchesFilter(fileTypeFilter, isOffline: viewState == .offline)
    }
}
