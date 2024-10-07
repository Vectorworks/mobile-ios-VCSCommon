//
//  File.swift
//
//
//  Created by Veneta Todorova on 29.08.24.
//

import Foundation

enum FileChooserRouteData: Hashable, Equatable {
    case sharedWithMe(MyFilesRouteData)
    case s3(MyFilesRouteData)
    case externalStorage(MyFilesRouteData)
    case sharedWithMeRoot
    case sharedLink(MyFilesRouteData)
    
    var displayName: String {
        switch self {
        case .s3(let routeData), .externalStorage(let routeData), .sharedWithMe(let routeData), .sharedLink(let routeData):
            routeData.displayName
        case .sharedWithMeRoot:
            "Shared with me".vcsLocalized
        }
    }
    
    var resourceUri: String {
        switch self {
        case .s3(let routeData), .externalStorage(let routeData), .sharedWithMe(let routeData), .sharedLink(let routeData):
            routeData.resourceUri
        case .sharedWithMeRoot:
            fatalError("Shared with me root resourceUri is nil.")
        }
    }
}

public struct MyFilesRouteData: Hashable, Identifiable {
    public let id = UUID()
    let resourceUri: String
    let displayName: String
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}



