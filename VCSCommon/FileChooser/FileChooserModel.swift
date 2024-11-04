//
//  File.swift
//
//
//  Created by Veneta Todorova on 4.09.24.
//

import Foundation

struct FileChooserModel: Identifiable {
    public let id: String

    let resourceUri: String
    let resourceId: String
    let flags: VCSFlagsResponse?
    let name: String
    let thumbnailUrl: URL?
    let lastDateModified: Date?
    let isAvailableOnDevice: Bool
    
    init(resourceUri: String, resourceId: String, flags: VCSFlagsResponse?, name: String, thumbnailUrl: URL?, lastDateModified: Date?, isAvailableOnDevice: Bool) {
        self.id = resourceId
        self.resourceUri = resourceUri
        self.resourceId = resourceId
        self.flags = flags
        self.name = name
        self.thumbnailUrl = thumbnailUrl
        self.lastDateModified = lastDateModified
        self.isAvailableOnDevice = isAvailableOnDevice
    }
}

extension Array where Element == FileChooserModel {
    func matchesFilter(_ fileTypeFilter: FileTypeFilter, isConnected: Bool) -> [FileChooserModel] {
        return self.filter { fileChooserModel in
            let matchesExtension = fileTypeFilter.extensions.map { filterExtension in
                fileChooserModel.name.range(of: filterExtension.rawValue, options: .caseInsensitive) != nil
            }.contains(true)

            if isConnected {
                return matchesExtension
            } else {
                return matchesExtension && fileChooserModel.isAvailableOnDevice
            }
        }
    }
}
