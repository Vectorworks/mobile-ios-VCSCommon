import Foundation
import SwiftData

@Model
public final class VCSSharedAssetWrapper: SharedAsset, Codable {
    //TODO: check cast
    public var asset: Asset { return self.fileAsset ?? self.folderAsset! }
    
    public let fileAsset: VCSFileResponse?
    public let folderAsset: VCSFolderResponse?
    
    public let assetType: AssetType
    public let resourceURI: String
    public let VCSID: String
    
    init(asset: Asset, assetType: AssetType, resourceURI: String) {
        if assetType == .folder {
            self.folderAsset = asset as? VCSFolderResponse
            self.VCSID = (asset as? VCSFolderResponse)?.rID ?? "nil"
        } else {
            self.fileAsset = asset as? VCSFileResponse
            self.VCSID = (asset as? VCSFileResponse)?.rID ?? "nil"
        }
        
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

extension VCSSharedAssetWrapper: VCSCacheable {
    public var rID: String { return VCSID }
}
