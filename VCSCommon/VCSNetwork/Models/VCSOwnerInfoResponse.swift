import Foundation
import SwiftData

@Model
public final class VCSOwnerInfoResponse: Codable {
    public var realmID: String = VCSUUID().systemUUID.uuidString
    
    public let owner: String
    public let ownerEmail: String
    public let ownerName: String
    public let uploadPrefix: String
    public let hasJoined: Bool
    public let permission: [SharedWithMePermission]
    public let dateCreated: String?
    public let sharedParentFolder: String
    @Relationship(deleteRule: .cascade)
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
    
    //Codable
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        owner = try container.decode(String.self, forKey: .owner)
        ownerEmail = try container.decode(String.self, forKey: .ownerEmail)
        ownerName = try container.decode(String.self, forKey: .ownerName)
        uploadPrefix = try container.decode(String.self, forKey: .uploadPrefix)
        hasJoined = try container.decode(Bool.self, forKey: .hasJoined)
        permission = try container.decode([SharedWithMePermission].self, forKey: .permission)
        dateCreated = try container.decode(String?.self, forKey: .dateCreated)
        sharedParentFolder = try container.decode(String.self, forKey: .sharedParentFolder)
        //TODO: REALM_CHANGE
//        mountPoint = try container.decode(VCSMountPointResponse?.self, forKey: .mountPoint)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(owner, forKey: .owner)
        try container.encode(ownerEmail, forKey: .ownerEmail)
        try container.encode(ownerName, forKey: .ownerName)
        try container.encode(uploadPrefix, forKey: .uploadPrefix)
        try container.encode(hasJoined, forKey: .hasJoined)
        try container.encode(permission, forKey: .permission)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(sharedParentFolder, forKey: .sharedParentFolder)
        try container.encode(mountPoint, forKey: .mountPoint)
    }
}

extension VCSOwnerInfoResponse: VCSCacheable {
    public var rID: String { return realmID }
}
