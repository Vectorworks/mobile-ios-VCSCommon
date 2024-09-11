//
//  File.swift
//
//
//  Created by Veneta Todorova on 29.08.24.
//

import Foundation

enum FileChooserRouteData: Hashable {
    case sharedWithMe(SharedWithMeRouteData)
    case s3(MyFilesRouteData)
    case externalStorage(MyFilesRouteData)
    case sharedWithMeRoot
    
    var displayName: String {
        switch self {
        case .sharedWithMe(let routeData):
            routeData.displayName
        case .s3(let routeData), .externalStorage(let routeData):
            routeData.displayName
        case .sharedWithMeRoot:
            "Shared with me".vcsLocalized
        }
    }
    
    var resourceUri: String {
        switch self {
        case .sharedWithMe(let routeData):
            routeData.resourceUri
        case .s3(let routeData), .externalStorage(let routeData):
            routeData.resourceUri
        case .sharedWithMeRoot:
            fatalError("Shared with me root resourceUri is nil.")
        }
    }
}

public struct SharedWithMeRouteData: Hashable, Identifiable {
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

public struct MyFilesRouteData: Hashable, Identifiable {
    public let id = UUID()
    let resourceUri: String
    let displayName: String
    
    init(resourceURI: String, displayName: String) {
        self.resourceUri = resourceURI
        self.displayName = displayName
    }
}



