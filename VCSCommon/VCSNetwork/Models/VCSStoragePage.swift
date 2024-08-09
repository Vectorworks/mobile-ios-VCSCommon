import UIKit
import Foundation

public typealias StoragePagesList = [StoragePage]

public enum StoragePageConstants: String {
    case GoogleDriveSharedWithMeID = "sharedWithMe"
    case OneDriveSharedWithMeID = "sharedWithMeOneDrive"
}


public class StoragePage: Codable {
    public static let driveIDRegXPattern: String = "driveId_[\\w\\-$!]+"
    public static let driveIDSharedRegXPattern: String = "driveId_sharedWithMe[\\w\\-$!]+"
    public static let driveIDSharedOneDriveRegXPattern: String = "driveId_sharedWithMeOneDrive[\\w\\-$!]+"
    public let id, name, folderURI: String
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
        let result = StoragePage.realmStorage.getAll().first(where: { (page: StoragePage) in uri.contains(page.id) })
        
        guard result?.name != StorageType.ONE_DRIVE.displayName else { return "" }
        
        return result?.displayName ?? ""
    }
}

extension StoragePage: VCSCachable {
    public typealias RealmModel = VCSRealmStoragPages
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        StoragePage.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if StoragePage.realmStorage.getByIdOfItem(item: self) != nil {
            StoragePage.realmStorage.partialUpdate(item: self)
        } else {
            StoragePage.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        StoragePage.realmStorage.partialUpdate(item: self)
    }
    
    public func deleteFromCache() {
        StoragePage.realmStorage.delete(item: self)
    }
}
