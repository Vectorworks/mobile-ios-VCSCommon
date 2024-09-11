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
}
