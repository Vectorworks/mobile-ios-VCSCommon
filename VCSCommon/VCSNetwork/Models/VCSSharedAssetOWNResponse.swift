import Foundation

public class VCSSharedAssetOWNResponse: SharedAsset, Codable {
    public let asset: Asset
    public let assetType: AssetType
    public let resourceURI: String
    public let owner, ownerEmail, ownerName, dateCreated: String
    
    private enum CodingKeys: String, CodingKey {
        case owner
        case ownerEmail = "owner_email"
        case ownerName = "owner_name"
        case dateCreated = "date_created"
        case asset
        case assetType = "asset_type"
        case resourceURI = "resource_uri"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.owner = try container.decode(String.self, forKey: CodingKeys.owner)
        self.ownerEmail = try container.decode(String.self, forKey: CodingKeys.ownerEmail)
        self.ownerName = try container.decode(String.self, forKey: CodingKeys.ownerName)
        self.dateCreated = try container.decode(String.self, forKey: CodingKeys.dateCreated)
        self.assetType = try container.decode(AssetType.self, forKey: CodingKeys.assetType)
        self.resourceURI = try container.decode(String.self, forKey: CodingKeys.resourceURI)
        
        switch self.assetType {
        case .file:
            self.asset = try container.decode(VCSFileResponse.self, forKey: CodingKeys.asset)
        case .folder:
            self.asset = try container.decode(VCSFolderResponse.self, forKey: CodingKeys.asset)
        }
        
        self.asset.updateSharedOwnerLogin(self.owner)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.owner, forKey: CodingKeys.owner)
        try container.encode(self.ownerEmail, forKey: CodingKeys.ownerEmail)
        try container.encode(self.ownerName, forKey: CodingKeys.ownerName)
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
    
    init(owner: String, ownerEmail: String, ownerName: String, dateCreated: String, asset: Asset, assetType: AssetType, resourceURI: String) {
        self.owner = owner
        self.ownerEmail = ownerEmail
        self.ownerName = ownerName
        self.dateCreated = dateCreated
        
        self.asset = asset
        self.assetType = assetType
        self.resourceURI = resourceURI
    }
}

extension VCSSharedAssetOWNResponse: VCSCachable {
    public typealias RealmModel = RealmSharedAssetOWN
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSSharedAssetOWNResponse.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSSharedAssetOWNResponse.realmStorage.getByIdOfItem(item: self) != nil {
            VCSSharedAssetOWNResponse.realmStorage.partialUpdate(item: self)
        } else {
            VCSSharedAssetOWNResponse.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSSharedAssetOWNResponse.realmStorage.partialUpdate(item: self)
    }
    
    public func deleteFromCache() {
        VCSSharedAssetOWNResponse.realmStorage.delete(item: self)
    }
}
