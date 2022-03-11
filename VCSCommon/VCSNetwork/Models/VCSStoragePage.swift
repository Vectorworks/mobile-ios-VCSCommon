import UIKit
import Foundation

public typealias StoragePagesList = [StoragePage]

@objc public class StoragePage: NSObject, Codable {
    @objc private static var cachedList: [String: StoragePage] = [:]
    @objc public static let driveIDRegXPattern: String = "driveId_[\\w\\-$!]+"
    @objc public static let driveIDSharedRegXPattern: String = "driveId_sharedWithMe[\\w\\-$!]+"
    @objc public let id, name, folderURI: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case folderURI = "folder_uri"
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
        let result = StoragePage.cachedList.first { (key: String, value: StoragePage) in
            uri.contains(value.id)
        }
        
        guard result?.value.name != StorageType.ONE_DRIVE.displayName else { return "" }
        
        return result?.value.name ?? ""
    }
    
    public static func appendResponse(_ response: StoragePagesList) {
        response.forEach { (page: StoragePage) in
            StoragePage.cachedList[page.id] = page
        }
    }
}
