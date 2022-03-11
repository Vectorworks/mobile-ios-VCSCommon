import Foundation

@objc public class VCSFileResponse: NSObject, Codable {
    private(set) public var isFolder = false
    private(set) public var isFile = true
    
    @objc public var resourceURI: String = ""
    @objc public var resourceID: String = ""
    @objc public var exists: Bool = false
    public var isNameValid: Bool = false
    public var name: String = ""
    @objc public var prefix: String
    
    public var sharingInfo: VCSSharingInfoResponse?
    public var flags: VCSFlagsResponse?
    public var ownerInfo: VCSOwnerInfoResponse?
    public var storageType: StorageType = .S3
    @objc public var storageTypeString: String { return self.storageType.rawValue }
    @objc public var storageTypeDisplayString: String { return self.storageType.displayName }
    
    @objc private(set) public var ownerLogin: String
    public func updateSharedOwnerLogin(_ login: String) {
        self.related.forEach { $0.updateSharedOwnerLogin(login) }
        self.ownerLogin = login
    }
    
    public let id: Int
    
    public var VCSID: String
    @objc public let downloadURL: String
    public let versionID, thumbnail, size, lastModified: String
    public let thumbnail3D: String?
    public let previousVersions: [VCSFileResponse]
    public let fileType: String?
    @objc private(set) public var localFile: LocalFile?
    @objc private(set) public var localFilesAppFile: LocalFilesAppFile?
    
    private var isOnDisk: Bool {
        
        if self.filesForDownload.count == 0 {
            return false
        }
        
        let result: Bool = self.filesForDownload.reduce(true) { (res, fileInProject) -> Bool in
            return res && (fileInProject.localFile?.exists ?? false)
        }
        
        return result
    }
    
    public func setLocalFile(_ newLocalFile: LocalFile?) {
        defer {
            //To force setting localFile to nil
            VCSCache.addToCache(item: self, forceNilValuesUpdate: true)
        }
        
        if let oldLocalFile = self.localFile {
            try? FileUtils.deleteItem(oldLocalFile.localPath)
        }
        self.localFile = newLocalFile
    }
    
    public func setLocalFilesAppFile(_ newLocalFilesAppFile: LocalFilesAppFile?) {
        defer {
            //To force setting localFile to nil
            VCSCache.addToCache(item: self, forceNilValuesUpdate: true)
        }
        
        if let localPath = self.localFilesAppFile?.localContainerURL?.path {
            try? FileUtils.deleteItem(localPath)
        }
        self.localFilesAppFile = newLocalFilesAppFile
    }
    
    public func loadLocalFiles() {
        if self.related.count == 0, let oldFile = VCSFileResponse.realmStorage.getById(id: self.rID) {
            if self.lastModified == oldFile.lastModified {
                self.related = oldFile.related
            } else {
                self.related = []
            }
        }
        
        //TODO: clean way to know LocalFile data lastModified
        self.filesForDownload.forEach {
            if let oldFile = VCSFileResponse.realmStorage.getById(id: $0.rID) {
                if $0.lastModified == oldFile.lastModified {
                    $0.localFile = oldFile.localFile
                    $0.localFilesAppFile = oldFile.localFilesAppFile //Files App
                } else {
                    print("REMOVE OLD - \($0.name)")
                    oldFile.setLocalFile(nil)
                    $0.setLocalFile(nil)
                    oldFile.setLocalFilesAppFile(nil) //Files App
                    $0.setLocalFilesAppFile(nil)
                }
            }
        }
    }
    
    public func updateSharingInfo(other: VCSSharingInfoResponse)
    {
        self.sharingInfo = other
        VCSCache.addToCache(item: self, forceNilValuesUpdate: true)
    }
    
    @objc public var related: [VCSFileResponse]
    public lazy var sortingDate: Date = { return self.lastModified.VCSDateFromISO8061 ?? Date() }()
    
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
        
        case id
        case versionID = "version_id"
        case thumbnail
        case thumbnail3D = "thumbnail_3d"
        case size
        case downloadURL = "download_url"
        case lastModified = "last_modified"
        case previousVersions = "previous_versions"
        case related
        case fileType = "file_type"
        case localFile
        case parentFolder
        
        case isFolder = "is_folder"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.resourceURI = try container.decode(String.self, forKey: CodingKeys.resourceURI)
        self.resourceID = try container.decode(String.self, forKey: CodingKeys.resourceID)
        self.exists = try container.decode(Bool.self, forKey: CodingKeys.exists)
        self.isNameValid = try container.decode(Bool.self, forKey: CodingKeys.isNameValid)
        self.name = try container.decode(String.self, forKey: CodingKeys.name)
        self.sharingInfo = try? container.decode(VCSSharingInfoResponse.self, forKey: CodingKeys.sharingInfo)
        self.prefix = try container.decode(String.self, forKey: CodingKeys.prefix)
        self.storageType = try container.decode(StorageType.self, forKey: CodingKeys.storageType)
        self.flags = try? container.decode(VCSFlagsResponse.self, forKey: CodingKeys.flags)
        self.ownerInfo = try? container.decode(VCSOwnerInfoResponse.self, forKey: CodingKeys.ownerInfo)
        
        self.id = try container.decode(Int.self, forKey: CodingKeys.id)
        self.versionID = try container.decode(String.self, forKey: CodingKeys.versionID)
        self.thumbnail = try container.decode(String.self, forKey: CodingKeys.thumbnail)
        self.thumbnail3D = try? container.decode(String.self, forKey: CodingKeys.thumbnail3D)
        self.size = try container.decode(String.self, forKey: CodingKeys.size)
        self.downloadURL = try container.decode(String.self, forKey: CodingKeys.downloadURL)
        self.lastModified = try container.decode(String.self, forKey: CodingKeys.lastModified)
        self.previousVersions = try container.decode([VCSFileResponse].self, forKey: CodingKeys.previousVersions)
        self.related = try container.decode([VCSFileResponse].self, forKey: CodingKeys.related)
        self.fileType = try? container.decode(String.self, forKey: CodingKeys.fileType)
        
        self.ownerLogin = self.ownerInfo?.owner ?? AuthCenter.shared.user?.login ?? ""
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
        
        try container.encode(self.id, forKey: CodingKeys.id)
        try container.encode(self.versionID, forKey: CodingKeys.versionID)
        try container.encode(self.thumbnail, forKey: CodingKeys.thumbnail)
        try container.encode(self.thumbnail3D, forKey: CodingKeys.thumbnail3D)
        try container.encode(self.size, forKey: CodingKeys.size)
        try container.encode(self.downloadURL, forKey: CodingKeys.downloadURL)
        try container.encode(self.lastModified, forKey: CodingKeys.lastModified)
//        try container.encode(self.previousVersions, forKey: CodingKeys.previousVersions)
//        try container.encode(self.related, forKey: CodingKeys.related)
        try container.encode(self.fileType, forKey: CodingKeys.fileType)
        
        try container.encode(self.isFolder, forKey: CodingKeys.isFolder)
        
    }
    
    init(id: Int,
         versionID: String,
         thumbnail: String,
         size: String,
         downloadURL: String,
         lastModified: String,
         thumbnail3D: String?,
         previousVersions: [VCSFileResponse],
         fileType: String?,
         related: [VCSFileResponse],
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
         localFile: LocalFile? = nil,
         localFilesAppFile: LocalFilesAppFile? = nil,
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
        
        self.id = id
        self.versionID = versionID
        self.thumbnail = thumbnail
        self.size = size
        self.downloadURL = downloadURL
        self.lastModified = lastModified
        self.thumbnail3D = thumbnail3D
        self.previousVersions = previousVersions
        self.fileType = fileType
        self.related = related
        self.localFile = localFile
        self.localFilesAppFile = localFilesAppFile
        self.ownerLogin = ownerLogin
        self.VCSID = VCSID
    }
    
    final public class func ==(lhs: VCSFileResponse, rhs: VCSFileResponse) -> Bool {
        return lhs.id == rhs.id
    }
}

extension VCSFileResponse : FileAsset {
    public var downloadURLString: String { return self.downloadURL }
    public var relatedFileAssets: [FileAsset] { return self.related }
    public var localPathString: String? { return self.localFile?.localPath }
    @objc public var realStorage: String { return self.ownerInfo?.mountPoint?.storageType.rawValue ?? self.storageType.rawValue }
    @objc public var realPrefix: String {
        let isMountPoint = self.flags?.isMountPoint ?? false
        let mountPointPath = self.ownerInfo?.mountPoint?.path.VCSNormalizedURLString() ?? self.prefix
        let prefix = self.prefix
        let result = isMountPoint ? mountPointPath : prefix
        return result
    }
}

extension VCSFileResponse : FileCellPresentable {
    public var rID: String { return self.VCSID }
    public var nameString: String { return (self.name) }
    public var hasWarning: Bool { return (self.flags?.hasWarning ?? true) }
    public var isShared: Bool { return (self.sharingInfo?.isShared ?? false) }
    public var hasLink: Bool { return !(self.sharingInfo?.link.isEmpty ?? true) }
    public var sharingInfoData: VCSSharingInfoResponse? { return self.sharingInfo }
    
    public var isAvailableOnDevice: Bool { return (self.isOnDisk) }
    public var filterShowingOffline: Bool { return self.isAvailableOnDevice }
    public var lastModifiedString: String { return (self.lastModified) }
    public var sizeString: String { return (self.size) }
    public var thumbnailURL: URL? {
        let stringURL = (self.thumbnail3D?.isEmpty ?? true) ? self.thumbnail : self.thumbnail3D!
        return URL(string: stringURL)
    }
    public var fileTypeString: String? { return (self.fileType) }
    public var permissions: [String] { return self.ownerInfo?.permission.map() { $0.rawValue } ??  [] }
    public func hasPermission(_ permission: String) -> Bool { self.permissions.contains(permission) }
}

extension VCSFileResponse: VCSCellDataHolder {
    public var cellData: VCSCellPresentable {
        return self
    }
    public var cellFileData: FileCellPresentable? {
        return self
    }
    public var assetData: Asset? {
        return self
    }
}

extension VCSFileResponse: VCSCachable {
    public typealias RealmModel = RealmFile
    public static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSFileResponse.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSFileResponse.realmStorage.getByIdOfItem(item: self) != nil {
            VCSFileResponse.realmStorage.partialUpdate(item: self)
        } else {
            VCSFileResponse.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSFileResponse.realmStorage.partialUpdate(item: self)
    }
}

extension VCSFileResponse {
    private static let relatedExtensions = [
        VCSFileType.PDF.rawValue : [VCSFileType.PDF, VCSFileType.VWSNAP, VCSFileType.XMLZIP]
        , VCSFileType.VWX.rawValue : [VCSFileType.VWG]
        , VCSFileType.VWXW.rawValue : [VCSFileType.VWG]
        , VCSFileType.VWXP.rawValue : [VCSFileType.VWG]
        , VCSFileType.VGX.rawValue : [VCSFileType.VGX]]
    
    public var filesForDownload: [VCSFileResponse] {
        let relatedAndSelf = self.related + [self]
        return relatedAndSelf.filter { (file) -> Bool in
            return VCSFileResponse.relatedExtensions[self.name.pathExtension.uppercased()]?.contains { $0.isInFileName(name: file.name) } ?? true
        }
    }
}

extension VCSFileResponse {
    static let defaultDateString = "21-12-2012"
}
