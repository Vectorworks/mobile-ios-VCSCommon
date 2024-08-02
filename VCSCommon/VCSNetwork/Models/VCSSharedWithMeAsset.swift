import Foundation
import SwiftData

@Model
public final class VCSSharedWithMeAsset: SharedAsset, Codable, Hashable {
    //TODO: check cast
    public var asset: Asset { return self.fileAsset ?? self.folderAsset! }
    
    public let fileAsset: VCSFileResponse?
    public let folderAsset: VCSFolderResponse?
    
    public let assetType: AssetType
    public let resourceURI: String
    public let owner: String
    public let ownerEmail: String
    public let ownerName: String
    public let dateCreated: String
    
    public let hasJoined: Bool
    public let permission: [SharedWithMePermission]
    public let sharedParentFolder: String
    public let sharedWithLogin: String?
    public let branding: VCSSharedAssetBrandingResponse?
    
    private enum CodingKeys: String, CodingKey {
        case owner
        case ownerEmail = "owner_email"
        case ownerName = "owner_name"
        case dateCreated = "date_created"
        case asset
        case assetType = "asset_type"
        case resourceURI = "resource_uri"
        case hasJoined = "has_joined"
        case permission
        case sharedParentFolder = "shared_parent_folder"
        case branding
    }
    
    init(owner: String, ownerEmail: String, ownerName: String, dateCreated: String, asset: Asset, assetType: AssetType, resourceURI: String, permission: [String], sharedParentFolder: String, sharedWithLogin: String?, branding: VCSSharedAssetBrandingResponse?) {
        self.owner = owner
        self.ownerEmail = ownerEmail
        self.ownerName = ownerName
        self.dateCreated = dateCreated
        
        if assetType == .folder {
            self.folderAsset = asset as? VCSFolderResponse
        } else {
            self.fileAsset = asset as? VCSFileResponse
        }
        
        self.assetType = assetType
        self.resourceURI = resourceURI
        
        self.hasJoined = true
        self.permission = permission.map { SharedWithMePermission(rawValue: $0) }
        self.sharedParentFolder = sharedParentFolder
        self.sharedWithLogin = sharedWithLogin
        self.branding = branding
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.owner = try container.decode(String.self, forKey: CodingKeys.owner)
        self.ownerEmail = try container.decode(String.self, forKey: CodingKeys.ownerEmail)
        self.ownerName = try container.decode(String.self, forKey: CodingKeys.ownerName)
        self.dateCreated = try container.decode(String.self, forKey: CodingKeys.dateCreated)
        let assetType = try container.decode(AssetType.self, forKey: CodingKeys.assetType)
        self.assetType = assetType
        
        switch assetType {
        case .file:
            self.fileAsset = try container.decode(VCSFileResponse.self, forKey: CodingKeys.asset)
        case .folder:
            self.folderAsset = try container.decode(VCSFolderResponse.self, forKey: CodingKeys.asset)
        }
        
        self.resourceURI = try container.decode(String.self, forKey: CodingKeys.resourceURI)
        self.hasJoined = try container.decode(Bool.self, forKey: CodingKeys.hasJoined)
        self.permission = try container.decode([SharedWithMePermission].self, forKey: CodingKeys.permission)
        self.sharedParentFolder = try container.decode(String.self, forKey: CodingKeys.sharedParentFolder)
        self.branding = try container.decode(VCSSharedAssetBrandingResponse.self, forKey: CodingKeys.branding)
        self.branding?.realmID = self.asset.rID
        self.asset.updateSharedOwnerLogin(self.owner)
        self.sharedWithLogin = VCSUser.savedUser?.login
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
        
        
        try container.encode(self.hasJoined, forKey: CodingKeys.hasJoined)
        try container.encode(self.permission, forKey: CodingKeys.permission)
        try container.encode(self.sharedParentFolder, forKey: CodingKeys.sharedParentFolder)
        try container.encode(self.branding, forKey: CodingKeys.branding)
    }
}

extension VCSSharedWithMeAsset: FileCellPresentable {
    public var rID: String { return self.asset.rID }
    public var name: String { return self.asset.name }
    public var hasWarning: Bool { return (self.asset.flags?.hasWarning ?? true) }
    public var isShared: Bool { return (self.asset.sharingInfo?.isShared ?? false) }
    public var hasLink: Bool { return !(self.asset.sharingInfo?.link.isEmpty ?? true) }
    public var sharingInfoData: VCSSharingInfoResponse? { return self.asset.sharingInfo }
    public var isAvailableOnDevice: Bool { return self.asset.isAvailableOnDevice }
    public var lastModifiedString: String { return (self.asset as? VCSFileResponse)?.lastModified ?? Date().VCSISO8061String }
    public var sizeString: String { return (self.asset as? VCSFileResponse)?.sizeString ?? "0 B" }
    public var thumbnailURL: URL? { return (self.asset as? VCSFileResponse)?.thumbnailURL }
    public var fileTypeString: String? { return (self.asset as? VCSFileResponse)?.fileTypeString }
    public var isFolder: Bool { return self.asset.isFolder }
    public var permissions: [String] { return self.permission.map { $0.rawValue } }
    public func hasPermission(_ permission: String) -> Bool { self.permissions.contains(permission) }
}

extension VCSSharedWithMeAsset: AssetWrapperWithSorting {
    public var sortingName: String { return name }
    public var sortingDate: Date { return self.dateCreated.VCSDateFromISO8061 ?? Date() }
    public var sortingSize: String { return sizeString }
    public var filterShowingOffline: Bool { return self.isAvailableOnDevice }
}

extension VCSSharedWithMeAsset: VCSCellDataHolder {
    public var cellData: VCSCellPresentable {
        return self
    }
    public var cellFileData: FileCellPresentable? {
        return self
    }
    public var assetData: Asset? {
        return self.asset
    }
    public func updateSharingInfo(other: VCSSharingInfoResponse) {
        //TODO: delete item?
        self.asset.updateSharingInfo(other: other)
    }
}

extension VCSSharedWithMeAsset: VCSCacheable {
}

extension VCSSharedWithMeAsset {
    public static func == (lhs: VCSSharedWithMeAsset, rhs: VCSSharedWithMeAsset) -> Bool {
        return lhs.asset.rID == rhs.asset.rID
    }
}
