import Foundation
import UIKit
import SwiftData

public typealias StoragePagesList = [StoragePage]

public enum StoragePageConstants: String {
    case GoogleDriveSharedWithMeID = "sharedWithMe"
    case OneDriveSharedWithMeID = "sharedWithMeOneDrive"
}


@Model
public final class StoragePage: Codable {
    public static let driveIDRegXPattern: String = "driveId_[\\w\\-$!]+"
    public static let driveIDSharedRegXPattern: String = "driveId_sharedWithMe[\\w\\-$!]+"
    public static let driveIDSharedOneDriveRegXPattern: String = "driveId_sharedWithMeOneDrive[\\w\\-$!]+"
    
    public let id: String
    public let name: String
    public let folderURI: String
    public let sharedPaths: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case folderURI = "folder_uri"
        case sharedPaths = "shared_paths"
    }
    
    init(id: String, name: String, folderURI: String, sharedPaths: [String]) {
        self.id = id
        self.name = name
        self.folderURI = folderURI
        self.sharedPaths = sharedPaths
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: CodingKeys.id)
        self.name = try container.decode(String.self, forKey: CodingKeys.name)
        self.folderURI = try container.decode(String.self, forKey: CodingKeys.folderURI)
        self.sharedPaths = try container.decode([String]?.self, forKey: CodingKeys.sharedPaths)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: CodingKeys.id)
        try container.encode(self.name, forKey: CodingKeys.name)
        try container.encode(self.folderURI, forKey: CodingKeys.folderURI)
        try container.encode(self.sharedPaths, forKey: CodingKeys.sharedPaths)
    }
    
    public func storageImage() -> UIImage? {
        guard self.storageImageName.isEmpty == false else { return nil }
        return UIImage(named: self.storageImageName)
    }
    
    public var storageImageName: String {
        var result = "google-shared-drive"

        switch self.id {
        case "myDrive":
            result = "google-drive"
        case StoragePageConstants.GoogleDriveSharedWithMeID.rawValue:
            result = "google-shared-with-me"
        case StoragePageConstants.OneDriveSharedWithMeID.rawValue:
            result = "onedrive-shared-with-me"
        default:
            result = "google-shared-drive"
        }
        
        if self.name == "My Files" {
            result = "onedrive-folder"
        }

        return result
    }
    
    public var displayName: String {
        switch self.name {
        case "My Drive":
            return self.name.vcsLocalized
        case "Shared with me":
            return self.name.vcsLocalized
        case "My Files":
            return self.name.vcsLocalized
        case "Shared":
            return self.name.vcsLocalized
        default:
            return self.name
        }
    }
}

extension StoragePage {
    public static func getNameFromURI(_ uri: String) -> String {
        //TODO: REALM_CHANGE
        return ""
//        let result = StoragePage.realmStorage.getAll().first(where: { (page: StoragePage) in uri.contains(page.id) })
//        
//        guard result?.name != StorageType.ONE_DRIVE.displayName else { return "" }
//        
//        return result?.displayName ?? ""
    }
}

extension StoragePage: VCSCacheable {
    public var rID: String { return id }
}
