import Foundation

public class VCSOwnerInfoResponse: NSObject, Codable {
    public var realmID: String = VCSUUID().systemUUID.uuidString
    
    public let owner, ownerEmail, ownerName, uploadPrefix: String
    public let hasJoined: Bool
    public let permission: [SharedWithMePermission]
    public let dateCreated: String?
    public let sharedParentFolder: String
    public let mountPoint: VCSMountPointResponse?
    
    enum CodingKeys: String, CodingKey {
        case owner
        case ownerEmail = "owner_email"
        case ownerName = "owner_name"
        case uploadPrefix = "upload_prefix"
        case hasJoined = "has_joined"
        case permission
        case dateCreated = "date_created"
        case sharedParentFolder = "shared_parent_folder"
        case mountPoint = "mount_point"
    }
    
    public init(owner: String, ownerEmail: String, ownerName: String, uploadPrefix: String, hasJoined: Bool, permission: [String], dateCreated: String, sharedParentFolder: String, mountPoint: VCSMountPointResponse?, realmID: String) {
        self.realmID = realmID
        self.owner = owner
        self.ownerEmail = ownerEmail
        self.ownerName = ownerName
        self.uploadPrefix = uploadPrefix
        self.permission = permission.map { SharedWithMePermission(rawValue: $0) }
        self.hasJoined = hasJoined
        self.dateCreated = dateCreated
        self.sharedParentFolder = sharedParentFolder
        self.mountPoint = mountPoint
    }
}

extension VCSOwnerInfoResponse: VCSCachable {
    public typealias RealmModel = RealmOwnerInfo
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSOwnerInfoResponse.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSOwnerInfoResponse.realmStorage.getByIdOfItem(item: self) != nil {
            VCSOwnerInfoResponse.realmStorage.partialUpdate(item: self)
        } else {
            VCSOwnerInfoResponse.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSOwnerInfoResponse.realmStorage.partialUpdate(item: self)
    }
}
