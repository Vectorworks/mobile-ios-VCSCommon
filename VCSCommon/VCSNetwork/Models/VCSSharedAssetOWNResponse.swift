import Foundation
import SwiftData

@Model
public final class VCSSharedAssetOWNResponse: SharedAsset, Codable {
    public var asset: Asset { return self.fileAsset ?? self.folderAsset! }
    @Relationship(deleteRule: .nullify)
    public let fileAsset: VCSFileResponse?
    @Relationship(deleteRule: .nullify)
    public let folderAsset: VCSFolderResponse?
    public let VCSID: String
    
    public let assetType: AssetType
    public let resourceURI: String
    public let owner: String
    public let ownerEmail: String
    public let ownerName: String
    public let dateCreated: String
    
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
        let assetType = try container.decode(AssetType.self, forKey: CodingKeys.assetType)
        self.assetType = assetType
        self.resourceURI = try container.decode(String.self, forKey: CodingKeys.resourceURI)
        
        switch assetType {
        case .file:
            let fileAsset = try container.decode(VCSFileResponse.self, forKey: CodingKeys.asset)
            self.fileAsset = fileAsset
            self.VCSID = fileAsset.rID
        case .folder:
            let folderAsset = try container.decode(VCSFolderResponse.self, forKey: CodingKeys.asset)
            self.folderAsset = folderAsset
            self.VCSID = folderAsset.rID
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
        self.assetType = assetType
        
        switch assetType {
        case .file:
            let fileAsset = asset as? VCSFileResponse
            self.fileAsset = fileAsset
            self.VCSID = fileAsset?.rID ?? "nil"
        case .folder:
            let folderAsset = asset as? VCSFolderResponse
            self.folderAsset = folderAsset
            self.VCSID = folderAsset?.rID ?? "nil"
        }
        self.resourceURI = resourceURI
    }
}

extension VCSSharedAssetOWNResponse: VCSCacheable {
    public var rID: String { return VCSID }
}
