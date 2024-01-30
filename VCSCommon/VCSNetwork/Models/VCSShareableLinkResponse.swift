import Foundation

@objc public class VCSShareableLinkResponse: NSObject, SharedAsset, Codable {
    public let link, uuid, expires: String
    public let dateCreated: String
    public let resourceURI: String
    
    public let owner: VCSShareableLinkOwner
    @objc public let asset: Asset
    @objc public let assetType: AssetType
    
    
    private enum CodingKeys: String, CodingKey {
        case link, uuid, expires
        case dateCreated = "date_created"
        case resourceURI = "resource_uri"
        
        case assetType = "asset_type"
        case asset
        
        case branding
        case owner
        case ownerEmail = "owner_email"
        case ownerName = "owner_name"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.link = try container.decode(String.self, forKey: CodingKeys.link)
        self.uuid = try container.decode(String.self, forKey: CodingKeys.uuid)
        self.expires = try container.decode(String.self, forKey: CodingKeys.expires)
        self.dateCreated = try container.decode(String.self, forKey: CodingKeys.dateCreated)
        self.assetType = try container.decode(AssetType.self, forKey: CodingKeys.assetType)
        self.resourceURI = try container.decode(String.self, forKey: CodingKeys.resourceURI)
        
        switch self.assetType {
        case .file:
            self.asset = try container.decode(VCSFileResponse.self, forKey: CodingKeys.asset)
        case .folder:
            self.asset = try container.decode(VCSFolderResponse.self, forKey: CodingKeys.asset)
        }
        
        let branding = try container.decode(VCSSharedAssetBrandingResponse.self, forKey: CodingKeys.branding)
        let owner = try container.decode(String.self, forKey: CodingKeys.owner)
        let ownerEmail = try container.decode(String.self, forKey: CodingKeys.ownerEmail)
        let ownerName = try container.decode(String.self, forKey: CodingKeys.ownerName)
        self.owner = VCSShareableLinkOwner(branding: branding, owner: owner, ownerEmail: ownerEmail, ownerName: ownerName)
        
        self.asset.updateSharedOwnerLogin(owner)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.owner.branding, forKey: CodingKeys.branding)
        try container.encode(self.link, forKey: CodingKeys.link)
        try container.encode(self.uuid, forKey: CodingKeys.uuid)
        try container.encode(self.expires, forKey: CodingKeys.expires)
        try container.encode(self.owner.owner, forKey: CodingKeys.owner)
        try container.encode(self.owner.ownerEmail, forKey: CodingKeys.ownerEmail)
        try container.encode(self.owner.ownerName, forKey: CodingKeys.ownerName)
        try container.encode(self.dateCreated, forKey: CodingKeys.dateCreated)
        try container.encode(self.assetType, forKey: CodingKeys.assetType)
        try container.encode(self.resourceURI, forKey: CodingKeys.resourceURI)
        
        switch self.assetType {
        case .file:
            if let fileAsset = self.asset as? VCSFileResponse {
                try container.encode(fileAsset, forKey: CodingKeys.asset)
            }
        case .folder:
            if let folderAsset = self.asset as? VCSFolderResponse {
                try container.encode(folderAsset, forKey: CodingKeys.asset)
            }
        }
    }
    
    init(link: String, uuid: String, expires: String, owner: VCSShareableLinkOwner, dateCreated: String, asset: Asset, assetType: AssetType, resourceURI: String) {
        self.link = link
        self.uuid = uuid
        self.expires = expires
        self.dateCreated = dateCreated
        self.resourceURI = resourceURI
        
        self.asset = asset
        self.assetType = assetType
        self.owner = owner
        
    }
}

extension VCSShareableLinkResponse: VCSCellDataHolder {
    public var cellData: VCSCellPresentable {
        //TODO: remove force cast
        return self.asset as! VCSCellPresentable
    }
    public var cellFileData: FileCellPresentable? {
        return self.asset as? FileCellPresentable
    }
    public var assetData: Asset? {
        return self.asset
    }
}


extension VCSShareableLinkResponse: VCSCachable {
    public typealias RealmModel = RealmShareableLinkResponse
    public static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSShareableLinkResponse.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSShareableLinkResponse.realmStorage.getByIdOfItem(item: self) != nil {
            VCSShareableLinkResponse.realmStorage.partialUpdate(item: self)
        } else {
            VCSShareableLinkResponse.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSShareableLinkResponse.realmStorage.partialUpdate(item: self)
    }
}
