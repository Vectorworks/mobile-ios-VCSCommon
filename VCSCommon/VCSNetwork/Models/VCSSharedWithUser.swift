import Foundation

public class VCSSharedWithUser: NSObject, Codable {
    public let email: String
    public let login: String?
    public let username: String?
    public let permissions: [String]
    public let hasJoined: Bool
    
    private enum CodingKeys: String, CodingKey {
        case email
        case login
        case username
        case permissions
        case hasJoined = "has_joined"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.email = try container.decode(String.self, forKey: CodingKeys.email)
        self.login = try container.decode(String?.self, forKey: CodingKeys.login)
        self.username = try container.decode(String?.self, forKey: CodingKeys.username)
        self.permissions = try container.decode([String].self, forKey: CodingKeys.permissions)
        self.hasJoined = try container.decode(Bool.self, forKey: CodingKeys.hasJoined)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.email, forKey: CodingKeys.email)
        try container.encode(self.login, forKey: CodingKeys.login)
        try container.encode(self.username, forKey: CodingKeys.username)
        try container.encode(self.permissions, forKey: CodingKeys.permissions)
        try container.encode(self.hasJoined, forKey: CodingKeys.hasJoined)
    }
    
    init(email: String, login: String?, username: String?, hasJoined: Bool, permissions: [String]) {
        self.email = email
        self.login = login
        self.username = username
        self.hasJoined = hasJoined
        self.permissions = permissions
    }
}

extension VCSSharedWithUser: VCSCachable {
    public typealias RealmModel = RealmSharedWithUser
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSSharedWithUser.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSSharedWithUser.realmStorage.getByIdOfItem(item: self) != nil {
            VCSSharedWithUser.realmStorage.partialUpdate(item: self)
        } else {
            VCSSharedWithUser.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSSharedWithUser.realmStorage.partialUpdate(item: self)
    }
}
