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
    let size: String?
    let isAvailableOnDevice: Bool
    let fileType: String?
    
    init(resourceUri: String, resourceId: String, flags: VCSFlagsResponse?, name: String, thumbnailUrl: URL?, lastDateModified: Date?, size: String?, isAvailableOnDevice: Bool, fileType: String?) {
        self.id = resourceId
        self.resourceUri = resourceUri
        self.resourceId = resourceId
        self.flags = flags
        self.name = name
        self.thumbnailUrl = thumbnailUrl
        self.lastDateModified = lastDateModified
        self.size = size
        self.isAvailableOnDevice = isAvailableOnDevice
        self.fileType = fileType
    }
}

extension Array where Element == FileChooserModel {
    func matchesFilter(_ fileTypeFilter: FileTypeFilter, isOnline: Bool) -> [FileChooserModel] {
        return self.filter { fileChooserModel in
            let matchesExtension = fileTypeFilter.extensions.map { filterExtension in
                filterExtension.isInFile(fileType: fileChooserModel.fileType ?? "", fileName: fileChooserModel.name)
            }.contains(true)

            if isOnline {
                return matchesExtension
            } else {
                return matchesExtension && fileChooserModel.isAvailableOnDevice
            }
        }
    }
}
