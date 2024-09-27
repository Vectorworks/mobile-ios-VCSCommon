//
//  File.swift
//
//
//  Created by Veneta Todorova on 4.09.24.
//

import Foundation

struct FileChooserModel {
    let resourceUri: String
    let resourceId: String?
    let flags: VCSFlagsResponse?
    let name: String
    let thumbnailUrl: URL?
    let isFolder: Bool
    let route: FileChooserRouteData?
    let lastDateModified: Date?
}

extension Array where Element == FileChooserModel {
    func matchesFilter(_ fileTypeFilter: FileTypeFilter) -> [FileChooserModel] {
        return self.filter { fileChooserModel in
            if fileChooserModel.isFolder {
                return true
            } else {
                return fileTypeFilter.extensions.map { filterExtension in
                    filterExtension.isInFileName(fileChooserModel.name)
                }.contains(true)
            }
        }
    }
}
