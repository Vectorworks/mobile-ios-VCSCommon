import Foundation

@objc public class VCSFolderResponse: NSObject, Asset, Codable {
    
    public static var addToCacheRootFolderID: String?
    
    
    private(set) public var isFolder = true
    private(set) public var isFile = false
    
    public var VCSID: String
    
    @objc public var resourceURI: String = ""
    @objc public var resourceID: String = ""
    @objc public var exists: Bool = false
    public var isNameValid: Bool = false
    public var name: String = ""
    @objc public var prefix: String = ""
    
    public var sharingInfo: VCSSharingInfoResponse?
    public var flags: VCSFlagsResponse?
    public var ownerInfo: VCSOwnerInfoResponse?
    public var storageType: StorageType = .S3
    @objc public var storageTypeString: String { return self.storageType.rawValue }
    @objc public var storageTypeDisplayString: String { return self.storageType.displayName }
    
    @objc private(set) public var ownerLogin: String
    public func updateSharedOwnerLogin(_ login: String) {
        self.subfolders?.forEach { $0.updateSharedOwnerLogin(login) }
        self.files?.forEach { $0.updateSharedOwnerLogin(login) }
        self.ownerLogin = login
    }
    
    public let parent: String?
    public let autoprocessParent: String?
    
    @objc private(set) public var files: [VCSFileResponse]?
    @objc private(set) public var subfolders: [VCSFolderResponse]?
    
    public func appendFile(_ file: VCSFileResponse) {
        self.files?.append(file)
        VCSCache.addToCache(item: self)
    }
    
    public func removeFile(_ file: VCSFileResponse) {
        if let index = self.files?.firstIndex(of: file) {
            self.files?.remove(at: index)
        }
        VCSCache.addToCache(item: self)
    }
    
    public func appendShallowFolder(_ folder: VCSFolderResponse) {
        self.subfolders?.append(folder)
        VCSCache.addToCache(item: self)
    }
    
    public func removeFolder(_ folder: VCSFolderResponse) {
        if let index = self.subfolders?.firstIndex(of: folder) {
            self.subfolders?.remove(at: index)
        }
        VCSCache.addToCache(item: self)
    }
    
    public var cachedFiles: [VCSFileResponse]? { return self.files?.filter { return $0.isAvailableOnDevice } }
    
    public func loadLocalFiles() {
        self.subfolders?.forEach {
            $0.loadLocalFiles()
        }
        self.files?.forEach {
            $0.loadLocalFiles()
        }
    }
    
    public func updateSharingInfo(other: VCSSharingInfoResponse)
    {
        self.sharingInfo = other
        VCSCache.addToCache(item: self, forceNilValuesUpdate: true)
    }

    public lazy var sortingDate: Date = { return Date() }()
    
    @objc public var realStorage: String { return self.ownerInfo?.mountPoint?.storageType.rawValue ?? self.storageType.rawValue }
    @objc public var realPrefix: String {
        let isMountPoint = self.flags?.isMountPoint ?? false
        let mountPointPath = self.ownerInfo?.mountPoint?.path.VCSNormalizedURLString() ?? self.prefix
        let prefix = self.prefix
        let result = isMountPoint ? mountPointPath : prefix
        return result
    }
    
    
    
    
    private enum CodingKeys: String, CodingKey {
        case storageType = "storage_type"
        case resourceURI = "resource_uri"
        case resourceID = "resource_id"
        case exists
        case isNameValid = "is_name_valid"
        case name
        case prefix
        case sharingInfo = "sharing_info"
        case flags
        case ownerInfo = "owner_info"
        
        case files, parent, subfolders, parentFolder
        case autoprocessParent = "autoprocess_parent"
        
        case isFolder = "is_folder"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.resourceURI = try container.decode(String.self, forKey: CodingKeys.resourceURI)
        self.resourceID = try container.decode(String.self, forKey: CodingKeys.resourceID)
        self.exists = try container.decode(Bool.self, forKey: CodingKeys.exists)
        self.isNameValid = try container.decode(Bool.self, forKey: CodingKeys.isNameValid)
        self.name = try container.decode(String.self, forKey: CodingKeys.name)
        self.prefix = try container.decode(String.self, forKey: CodingKeys.prefix)
        self.storageType = try container.decode(StorageType.self, forKey: CodingKeys.storageType)
        self.flags = try? container.decode(VCSFlagsResponse.self, forKey: CodingKeys.flags)
        self.ownerInfo = try? container.decode(VCSOwnerInfoResponse.self, forKey: CodingKeys.ownerInfo)
        self.sharingInfo = try? container.decode(VCSSharingInfoResponse.self, forKey: CodingKeys.sharingInfo)
        self.files = try? container.decode([VCSFileResponse].self, forKey: CodingKeys.files)
        self.parent = try? container.decode(String.self, forKey: CodingKeys.parent)
        self.subfolders = try? container.decode([VCSFolderResponse].self, forKey: CodingKeys.subfolders)
        self.autoprocessParent = try? container.decode(String.self, forKey: CodingKeys.autoprocessParent)
        
        self.ownerLogin = self.ownerInfo?.owner ?? AuthCenter.shared.user?.login ?? ""
        
        if self.resourceID == "__invalid__",
           self.name == "" {
            self.resourceID = self.storageType.itemIdentifier.appendingPathComponent(self.prefix)
        }
        
        self.VCSID = self.resourceID
                
        super.init()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.resourceURI, forKey: CodingKeys.resourceURI)
        try container.encode(self.resourceID, forKey: CodingKeys.resourceID)
        try container.encode(self.exists, forKey: CodingKeys.exists)
        try container.encode(self.isNameValid, forKey: CodingKeys.isNameValid)
        try container.encode(self.name, forKey: CodingKeys.name)
        try container.encode(self.prefix, forKey: CodingKeys.prefix)
        try container.encode(self.sharingInfo, forKey: CodingKeys.sharingInfo)
        try container.encode(self.flags, forKey: CodingKeys.flags)
        try container.encode(self.storageType, forKey: CodingKeys.storageType)
        try container.encode(self.ownerInfo, forKey: CodingKeys.ownerInfo)
        
//        try container.encode(self.files, forKey: CodingKeys.files)
        try container.encode(self.parent, forKey: CodingKeys.parent)
//        try container.encode(self.subfolders, forKey: CodingKeys.subfolders)
        try container.encode(self.autoprocessParent, forKey: CodingKeys.autoprocessParent)
        
        try container.encode(self.isFolder, forKey: CodingKeys.isFolder)
    }
    
    public init(files: [VCSFileResponse]?,
                parent: String?,
                subfolders: [VCSFolderResponse]?,
                autoprocessParent: String?,
                resourceURI: String,
                resourceID: String,
                exists: Bool,
                isNameValid: Bool,
                name: String,
                sharingInfo: VCSSharingInfoResponse? = nil,
                prefix: String,
                storageType: StorageType,
                flags: VCSFlagsResponse? = nil,
                ownerInfo: VCSOwnerInfoResponse? = nil,
                ownerLogin: String,
                VCSID: String) {
        
        self.resourceURI = resourceURI
        self.resourceID = resourceID
        self.exists = exists
        self.isNameValid = isNameValid
        self.name = name
        self.sharingInfo = sharingInfo
        self.prefix = prefix
        self.storageType = storageType
        self.flags = flags
        self.ownerInfo = ownerInfo
        
        self.files = files
        self.parent = parent
        self.subfolders = subfolders
        self.autoprocessParent = autoprocessParent
        self.ownerLogin = ownerLogin
        self.VCSID = VCSID
    }
}

extension VCSFolderResponse: VCSCellPresentable {
    public var rID: String { return self.VCSID }
    public var hasWarning: Bool { return (self.flags?.hasWarning ?? true) }
    public var isShared: Bool { return (self.sharingInfo?.isShared ?? false) }
    public var hasLink: Bool { return !(self.sharingInfo?.link.isEmpty ?? true) }
    public var sharingInfoData: VCSSharingInfoResponse? { return self.sharingInfo }
    public var isAvailableOnDevice: Bool {
        if (self.files == nil && self.subfolders == nil) {
            return false
        }
        
        return self.files!.contains { return $0.isAvailableOnDevice }
            || self.subfolders!.contains { return $0.isAvailableOnDevice }
    }
    
    public var filterShowingOffline: Bool { return self.isAvailableOnDevice }
    public var permissions: [String] { return self.ownerInfo?.permission.map() { $0.rawValue } ??  [] }
    public func hasPermission(_ permission: String) -> Bool { self.permissions.contains(permission) }
}

extension VCSFolderResponse: VCSCellDataHolder {
    public var cellData: VCSCellPresentable {
        return self
    }
    public var cellFileData: FileCellPresentable? {
        return nil
    }
    public var assetData: Asset? {
        return self
    }
}

extension VCSFolderResponse: VCSCachable {
    public typealias RealmModel = RealmFolder
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSFolderResponse.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSFolderResponse.realmStorage.getByIdOfItem(item: self) != nil {
            VCSFolderResponse.realmStorage.partialUpdate(item: self)
        } else {
            VCSFolderResponse.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSFolderResponse.realmStorage.partialUpdate(item: self)
    }
}
