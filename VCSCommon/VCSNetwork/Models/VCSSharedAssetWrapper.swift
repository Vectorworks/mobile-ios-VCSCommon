import Foundation

public class VCSSharedAssetWrapper: NSObject, SharedAsset, Codable {
    public let asset: Asset
    public let assetType: AssetType
    public let resourceURI: String
    
    init(asset: Asset, assetType: AssetType, resourceURI: String) {
        self.asset = asset
        self.assetType = assetType
        self.resourceURI = resourceURI
    }
    
    private enum CodingKeys: String, CodingKey {
        case asset
        case assetType = "asset_type"
        case resourceURI = "resource_uri"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.assetType = try container.decode(AssetType.self, forKey: CodingKeys.assetType)
        self.resourceURI = try container.decode(String.self, forKey: CodingKeys.resourceURI)
        
        switch self.assetType {
        case .file:
            self.asset = try container.decode(VCSFileResponse.self, forKey: CodingKeys.asset)
        case .folder:
            self.asset = try container.decode(VCSFolderResponse.self, forKey: CodingKeys.asset)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
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
}

extension VCSSharedAssetWrapper: VCSCellDataHolder {
    public var cellData: VCSCellPresentable {
        //TODO: remove force cast
        return self.asset as! VCSCellPresentable
    }
    public var cellFileData: FileCellPresentable? {
        return self.asset as? VCSFileResponse
    }
    public var assetData: Asset? {
        return self.asset
    }
    public func updateSharingInfo(other: VCSSharingInfoResponse) {
        self.asset.updateSharingInfo(other: other)
        if (other.sharedWith?.count ?? 0) == 0 {
            self.deleteFromCache()
        }
    }
}

extension VCSSharedAssetWrapper: VCSCachable {
    public typealias RealmModel = RealmSharedAsset
    public static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSSharedAssetWrapper.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSSharedAssetWrapper.realmStorage.getByIdOfItem(item: self) != nil {
            VCSSharedAssetWrapper.realmStorage.partialUpdate(item: self)
        } else {
            VCSSharedAssetWrapper.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSSharedAssetWrapper.realmStorage.partialUpdate(item: self)
    }
    
    public func deleteFromCache() {
        VCSSharedAssetWrapper.realmStorage.delete(item: self)
    }
}
