import UIKit
import Foundation

public typealias StoragePagesList = [StoragePage]

@objc public class StoragePage: NSObject, Codable {
    @objc public static let driveIDRegXPattern: String = "driveId_[\\w\\-$!]+"
    @objc public static let driveIDSharedRegXPattern: String = "driveId_sharedWithMe[\\w\\-$!]+"
    @objc public let id, name, folderURI: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case folderURI = "folder_uri"
    }
    
    init(id: String, name: String, folderURI: String) {
        self.id = id
        self.name = name
        self.folderURI = folderURI
    }
    
    public func storageImage() -> UIImage? {
        guard self.storageImageName.isEmpty == false else { return nil }
        return UIImage(named: self.storageImageName)
    }
    
    public var storageImageName: String {
        switch self.id {
        case "myDrive":
            return "google-drive"
        case "sharedWithMe":
            return "google-shared-with-me"
        default:
            return "google-shared-drive"
        }
    }
}

extension StoragePage {
    public static func getNameFromURI(_ uri: String) -> String {
        let result = StoragePage.realmStorage.getAll().first(where: { (page: StoragePage) in uri.contains(page.id) })
        
        guard result?.name != StorageType.ONE_DRIVE.displayName else { return "" }
        
        return result?.name ?? ""
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
}
