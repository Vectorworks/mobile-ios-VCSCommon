import UIKit
import Foundation

@objc public class VCSStorageResponse: NSObject, Codable {
    @objc public let name, folderURI, fileURI: String
    public let storageType: StorageType
    @objc public let resourceURI: String
    @objc public let autoprocessParent: String?
    @objc public let accessType: String?
    @objc public let pagesURL: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case storageType = "storage_type"
        case folderURI = "folder_uri"
        case fileURI = "file_uri"
        case resourceURI = "resource_uri"
        case autoprocessParent = "autoprocess_parent"
        case accessType = "access_type"
        case pagesURL = "pages_url"
    }
    
    init(name: String, folderURI: String, fileURI: String, storageType: StorageType, resourceURI: String, autoprocessParent: String?, accessType: String?, pagesURL: String?) {
        self.name = name
        self.folderURI = folderURI
        self.fileURI = fileURI
        self.storageType = storageType
        self.resourceURI = resourceURI
        self.autoprocessParent = autoprocessParent
        self.accessType = accessType
        self.pagesURL = pagesURL
    }
    
    public func storageImage() -> UIImage? {
        return UIImage(named: self.storageType.storageImageName)
    }
}

extension VCSStorageResponse: VCSCachable {
    public typealias RealmModel = VCSRealmStorage
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSStorageResponse.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSStorageResponse.realmStorage.getByIdOfItem(item: self) != nil {
            VCSStorageResponse.realmStorage.partialUpdate(item: self)
        } else {
            VCSStorageResponse.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSStorageResponse.realmStorage.partialUpdate(item: self)
    }
}
