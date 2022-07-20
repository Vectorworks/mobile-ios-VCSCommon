import Foundation

@objc public class VCSSharingInfoResponse: NSObject, Codable {
    private(set) public var realmID: String = UUID().uuidString
    public let isShared: Bool
    public let link: String
    public let linkUUID: String
    public let linkExpires: String
    public let linkVisitsCount: Int
    public let allowComments: Bool
    
    public let sharedWith: [VCSSharedWithUser]?
    public let resourceURI: String
    public let lastShareDate: String?
    
    public func setNewRealmID(_ realmID: String) {
        self.realmID = realmID
    }
    
    private enum CodingKeys: String, CodingKey {
        case isShared = "is_shared"
        case link = "link"
        case linkUUID = "link_uuid"
        case linkExpires = "link_expires"
        case linkVisitsCount = "link_visits_count"
        case allowComments = "allow_comments"
        
        case sharedWith = "shared_with"
        case resourceURI = "resource_uri"
        case lastShareDate = "last_share_date"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.isShared = try container.decode(Bool.self, forKey: CodingKeys.isShared)
        self.link = (try? container.decode(String.self, forKey: CodingKeys.link)) ?? ""
        self.linkUUID = (try? container.decode(String.self, forKey: CodingKeys.linkUUID)) ?? ""
        self.linkExpires = (try? container.decode(String.self, forKey: CodingKeys.linkExpires)) ?? ""
        self.linkVisitsCount = (try? container.decode(Int.self, forKey: CodingKeys.linkVisitsCount)) ?? 0
        self.allowComments = (try? container.decode(Bool.self, forKey: CodingKeys.allowComments)) ?? false
        
        self.sharedWith = try container.decode([VCSSharedWithUser].self, forKey: CodingKeys.sharedWith)
        self.resourceURI = try container.decode(String.self, forKey: CodingKeys.resourceURI)
        self.lastShareDate = try? container.decode(String.self, forKey: CodingKeys.lastShareDate)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.isShared, forKey: CodingKeys.isShared)
        try container.encode(self.link, forKey: CodingKeys.link)
        try container.encode(self.linkUUID, forKey: CodingKeys.linkUUID)
        try container.encode(self.linkExpires, forKey: CodingKeys.linkExpires)
        try container.encode(self.linkVisitsCount, forKey: CodingKeys.linkVisitsCount)
        try container.encode(self.allowComments, forKey: CodingKeys.allowComments)
        
        try container.encode(self.sharedWith, forKey: CodingKeys.sharedWith)
        try container.encode(self.resourceURI, forKey: CodingKeys.resourceURI)
        try container.encode(self.lastShareDate, forKey: CodingKeys.lastShareDate)
    }
    
    init(isShared: Bool, link: String, linkUUID: String, linkExpires: String, linkVisitsCount: Int = 0, allowComments: Bool = false, sharedWith: [VCSSharedWithUser], resourceURI: String, lastShareDate: String? = nil, realmID: String) {
        self.realmID = realmID
        self.isShared = isShared
        self.link = link
        self.linkUUID = linkUUID
        self.linkExpires = linkExpires
        self.linkVisitsCount = linkVisitsCount
        self.allowComments = allowComments
        self.sharedWith = sharedWith
        self.resourceURI = resourceURI
        self.lastShareDate = lastShareDate
    }
}

extension VCSSharingInfoResponse: VCSCachable {
    public typealias RealmModel = RealmSharingInfo
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSSharingInfoResponse.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSSharingInfoResponse.realmStorage.getByIdOfItem(item: self) != nil {
            VCSSharingInfoResponse.realmStorage.partialUpdate(item: self)
        } else {
            VCSSharingInfoResponse.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSSharingInfoResponse.realmStorage.partialUpdate(item: self)
    }
}
