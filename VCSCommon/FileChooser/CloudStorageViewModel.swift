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

class CloudStorageViewModel: ObservableObject, FileLoadable {
    @Published var viewState: ViewState = .loading
    
    @Published var fileTypeFilter: FileTypeFilter
    
    var sharedWithMe: Bool {
        false
    }
    
    init(fileTypeFilter: FileTypeFilter) {
        self.fileTypeFilter = fileTypeFilter
    }
    
    func filterAndMapToModels(
        allFiles: Results<VCSFileResponse.RealmModel>,
        storageType: String
    ) -> [FileChooserModel] {
        return allFiles
            .filter { $0.storageType == storageType }
            .sorted(by: { $0.lastModified > $1.lastModified })
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
            .matchesFilter(fileTypeFilter, isOffline: viewState == .offline)
    }
}
