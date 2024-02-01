import Foundation

public class VCSShareableLinkOwner: NSObject, Codable {
    public let branding: VCSSharedAssetBrandingResponse
    public let owner, ownerEmail, ownerName: String
    
    private enum CodingKeys: String, CodingKey {
        case branding
        case owner
        case ownerEmail = "owner_email"
        case ownerName = "owner_name"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.branding = try container.decode(VCSSharedAssetBrandingResponse.self, forKey: CodingKeys.branding)
        self.owner = try container.decode(String.self, forKey: CodingKeys.owner)
        self.ownerEmail = try container.decode(String.self, forKey: CodingKeys.ownerEmail)
        self.ownerName = try container.decode(String.self, forKey: CodingKeys.ownerName)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.branding, forKey: CodingKeys.branding)
        try container.encode(self.owner, forKey: CodingKeys.owner)
        try container.encode(self.ownerEmail, forKey: CodingKeys.ownerEmail)
        try container.encode(self.ownerName, forKey: CodingKeys.ownerName)
    }
    
    init(branding: VCSSharedAssetBrandingResponse, owner: String, ownerEmail: String, ownerName: String) {
        self.branding = branding
        
        self.owner = owner
        self.ownerEmail = ownerEmail
        self.ownerName = ownerName
    }
}

extension VCSShareableLinkOwner: VCSCachable {
    public typealias RealmModel = RealmShareableLinkOwner
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSShareableLinkOwner.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSShareableLinkOwner.realmStorage.getByIdOfItem(item: self) != nil {
            VCSShareableLinkOwner.realmStorage.partialUpdate(item: self)
        } else {
            VCSShareableLinkOwner.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSShareableLinkOwner.realmStorage.partialUpdate(item: self)
    }
}

