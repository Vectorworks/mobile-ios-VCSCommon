//
//  File.swift
//
//
//  Created by Veneta Todorova on 29.08.24.
//

import Foundation

enum FileChooserRouteData: Hashable, Equatable {
    case s3(MyFilesRouteData)
    case dropbox(MyFilesRouteData)
    case oneDrive(MyFilesRouteData)
    case googleDrive(MyFilesRouteData)
    case sharedWithMeRoot
    
    var displayName: String {
        switch self {
        case .s3(let routeData), .dropbox(let routeData), .oneDrive(let routeData), .googleDrive(let routeData):
            routeData.displayName
        case .sharedWithMeRoot:
            "Shared with me".vcsLocalized
        }
    }
    
    var resourceUri: String {
        switch self {
        case .s3(let routeData), .dropbox(let routeData), .oneDrive(let routeData), .googleDrive(let routeData):
            routeData.resourceUri
        case .sharedWithMeRoot:
            fatalError("Shared with me root resourceUri is nil.")
        }
    }

    var storageType: StorageType {
        switch self {
        case .s3:
            return .S3
        case .dropbox:
            return .DROPBOX
        case .oneDrive:
            return .ONE_DRIVE
        case .googleDrive:
            return .GOOGLE_DRIVE
        default:
            fatalError("Invalid storageType")
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



