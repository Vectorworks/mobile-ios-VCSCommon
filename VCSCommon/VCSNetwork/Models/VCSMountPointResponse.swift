import Foundation

public class VCSMountPointResponse: NSObject, Codable {
    public var realmID: String = VCSUUID().systemUUID.uuidString
    
    public let storageType: StorageType
    public let prefix, path, mountPath: String
    
    enum CodingKeys: String, CodingKey {
        case storageType = "storage_type"
        case prefix = "prefix"
        case path = "path"
        case mountPath = "mount_path"
    }
    
    public init(storageType: StorageType, prefix: String, path: String, mountPath: String, realmID: String) {
        self.realmID = realmID
        self.storageType = storageType
        self.prefix = prefix
        self.path = path
        self.mountPath = mountPath
    }
}

extension VCSMountPointResponse: VCSCachable {
    public typealias RealmModel = RealmMountPoint
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSMountPointResponse.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSMountPointResponse.realmStorage.getByIdOfItem(item: self) != nil {
            VCSMountPointResponse.realmStorage.partialUpdate(item: self)
        } else {
            VCSMountPointResponse.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSMountPointResponse.realmStorage.partialUpdate(item: self)
    }
}
