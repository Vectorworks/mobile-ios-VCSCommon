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
    
    public var displayedPrefix: String {
        var result = self.storageTypeDisplayString
        let prefixes = self.prefix.split(separator: "/")
        prefixes.forEach {
            result = result.appendingPathComponent(String($0))
        }
        return result
    }
    
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

public extension VCSFolderResponse {
    static var testVCSFolder: VCSFolderResponse? = { return try? JSONDecoder().decode(VCSFolderResponse.self, from: VCSFolderResponse.testFolderJSONString.data(using: .utf8)!) }()
    
    static var testFolderJSONString = """
{
    "resource_id": "__invalid__",
    "storage_type": "s3",
    "name": "",
    "is_name_valid": true,
    "prefix": "/",
    "exists": true,
    "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/",
    "sharing_info": {
        "is_shared": false,
        "link": null,
        "link_uuid": null,
        "link_expires": null,
        "link_visits_count": null,
        "shared_with": [],
        "resource_uri": "",
        "last_share_date": "1970-01-01T05:00:00.000Z",
        "allow_comments": null
    },
    "flags": {
        "is_supported": true,
        "is_name_valid": true,
        "is_file_type_supported": true,
        "is_name_duplicate": false,
        "is_mounted": false,
        "is_mount_point": false,
        "is_google_trashable": true
    },
    "owner_info": {
        "owner": "azumpalova",
        "owner_email": "azumpalova@vectorworks.net",
        "owner_name": "Anna Zumpalova",
        "upload_prefix": "annazumpalova",
        "owner_region": "fr",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
    },
    "files": [
        {
            "id": 2585803,
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkAQDExZWQwMmEyYjNiNGI4M2FiN2RkMGViMTZhYWM3Y2Fm",
            "thumbnail_3d": "https://s3.eu-west-3.amazonaws.com/vectorworks-vcs-test-storage-fr-internal/annazumpalova/s3/Public%20Library%20v2022%20v2023b217.38e8a7adeefcececb784d9efc0b0f788.vwx.png",
            "version_id": "79yyTMvXUrH6JJA0SFoGsA4V91Vj1cND",
            "thumbnail": "https://s3.eu-west-3.amazonaws.com/vectorworks-vcs-test-storage-fr-internal/annazumpalova/s3/Public%20Library%20v2022%20v2023b217.be032c5f277e3ea0db83a243d60bd8fb.png",
            "storage_type": "s3",
            "size": "17120402",
            "resource_uri": "/restapi/public/v2/s3/file/o:azumpalova/p:Public%20Library%20v2022%20v2023b217.vwx/id:11ed02a2b3b4b83ab7dd0eb16aac7caf/v:79yyTMvXUrH6JJA0SFoGsA4V91Vj1cND/",
            "download_url": "/restapi/public/v2/s3/file/:download/o:azumpalova/p:Public%20Library%20v2022%20v2023b217.vwx/id:11ed02a2b3b4b83ab7dd0eb16aac7caf/v:79yyTMvXUrH6JJA0SFoGsA4V91Vj1cND/",
            "exists": true,
            "is_name_valid": true,
            "last_modified": "2022-08-23T07:42:50.000Z",
            "name": "Public Library v2022 v2023b217.vwx",
            "prefix": "Public Library v2022 v2023b217.vwx",
            "previous_versions": [],
            "related": [],
            "sharing_info": {
                "is_shared": false,
                "link": "/links/11ed1e2b3c9cf2e3bae20eb16aac7caf/",
                "link_uuid": "11ed1e2b3c9cf2e3bae20eb16aac7caf",
                "link_expires": "9999-12-31T23:59:59Z",
                "link_visits_count": 0,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "2022-08-23T07:48:07.000Z",
                "allow_comments": true
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "file_type": "VWX",
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            }
        },
        {
            "id": 2591738,
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkAQDExZWQyMzdiZTdjMDhjZTNiMWQ3MGViMTZhYWM3Y2Fm",
            "thumbnail_3d": "",
            "version_id": "HYzLJxiNr1V5flkU1a.vA9dYWFVUxu6E",
            "thumbnail": "",
            "storage_type": "s3",
            "size": "0",
            "resource_uri": "/restapi/public/v2/s3/file/o:azumpalova/p:Room_20220824-101055.7140.obj/id:11ed237be7c08ce3b1d70eb16aac7caf/v:HYzLJxiNr1V5flkU1a.vA9dYWFVUxu6E/",
            "download_url": "/restapi/public/v2/s3/file/:download/o:azumpalova/p:Room_20220824-101055.7140.obj/id:11ed237be7c08ce3b1d70eb16aac7caf/v:HYzLJxiNr1V5flkU1a.vA9dYWFVUxu6E/",
            "exists": true,
            "is_name_valid": true,
            "last_modified": "2022-08-24T07:11:00.000Z",
            "name": "Room_20220824-101055.7140.obj",
            "prefix": "Room_20220824-101055.7140.obj",
            "previous_versions": [],
            "related": [],
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "file_type": "OTHER",
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            }
        },
        {
            "id": 2591740,
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkAQDExZWQyMzdiZTdkMWExOTVhNjQyMGViMTZhYWM3Y2Fm",
            "thumbnail_3d": "",
            "version_id": "cZKiGMUXiSfDxIhzr76BNldVXxtzulZm",
            "thumbnail": "",
            "storage_type": "s3",
            "size": "37714",
            "resource_uri": "/restapi/public/v2/s3/file/o:azumpalova/p:Room_20220824-101055.7140.usdz/id:11ed237be7d1a195a6420eb16aac7caf/v:cZKiGMUXiSfDxIhzr76BNldVXxtzulZm/",
            "download_url": "/restapi/public/v2/s3/file/:download/o:azumpalova/p:Room_20220824-101055.7140.usdz/id:11ed237be7d1a195a6420eb16aac7caf/v:cZKiGMUXiSfDxIhzr76BNldVXxtzulZm/",
            "exists": true,
            "is_name_valid": true,
            "last_modified": "2022-08-24T07:11:00.000Z",
            "name": "Room_20220824-101055.7140.usdz",
            "prefix": "Room_20220824-101055.7140.usdz",
            "previous_versions": [],
            "related": [],
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "file_type": "OTHER",
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            }
        },
        {
            "id": 2591745,
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkAQDExZWQyMzdiZTdkOTc2NDVhNTc3MGViMTZhYWM3Y2Fm",
            "thumbnail_3d": "",
            "version_id": "7tEVBuKChhiKKgnT2cXHBsjFvSeEv4WG",
            "thumbnail": "",
            "storage_type": "s3",
            "size": "0",
            "resource_uri": "/restapi/public/v2/s3/file/o:azumpalova/p:Room_20220824-101055.7140.mtl/id:11ed237be7d97645a5770eb16aac7caf/v:7tEVBuKChhiKKgnT2cXHBsjFvSeEv4WG/",
            "download_url": "/restapi/public/v2/s3/file/:download/o:azumpalova/p:Room_20220824-101055.7140.mtl/id:11ed237be7d97645a5770eb16aac7caf/v:7tEVBuKChhiKKgnT2cXHBsjFvSeEv4WG/",
            "exists": true,
            "is_name_valid": true,
            "last_modified": "2022-08-24T07:11:00.000Z",
            "name": "Room_20220824-101055.7140.mtl",
            "prefix": "Room_20220824-101055.7140.mtl",
            "previous_versions": [],
            "related": [],
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "file_type": "OTHER",
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            }
        },
        {
            "id": 2603403,
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkAQDExZWQyM2EyZTMwYmM2NTVhNmE0MGViMTZhYWM3Y2Fm",
            "thumbnail_3d": "https://s3.eu-west-3.amazonaws.com/vectorworks-vcs-test-storage-fr-internal/annazumpalova/s3/Public%20Library%20v2022%20v2023b217.38e8a7adeefcececb784d9efc0b0f788.vwx.png",
            "version_id": "B2WAhMQDJ0GgTHmbu7Fp_DkR0yJnKMxl",
            "thumbnail": "",
            "storage_type": "s3",
            "size": "394645",
            "resource_uri": "/restapi/public/v2/s3/file/o:azumpalova/p:Public%20Library%20v2022%20v2023b217.vgx/id:11ed23a2e30bc655a6a40eb16aac7caf/v:B2WAhMQDJ0GgTHmbu7Fp_DkR0yJnKMxl/",
            "download_url": "/restapi/public/v2/s3/file/:download/o:azumpalova/p:Public%20Library%20v2022%20v2023b217.vgx/id:11ed23a2e30bc655a6a40eb16aac7caf/v:B2WAhMQDJ0GgTHmbu7Fp_DkR0yJnKMxl/",
            "exists": true,
            "is_name_valid": true,
            "last_modified": "2022-08-29T10:57:23.000Z",
            "name": "Public Library v2022 v2023b217.vgx",
            "prefix": "Public Library v2022 v2023b217.vgx",
            "previous_versions": [],
            "related": [],
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "file_type": "VGX",
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            }
        },
        {
            "id": 2595121,
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkAQDExZWQyNDNlMDI1YzJmMjhiOTFmMGViMTZhYWM3Y2Fm",
            "thumbnail_3d": "",
            "version_id": "CH.u5JEHjhRkLgm253CUV_eznkqEbzUn",
            "thumbnail": "https://s3.eu-west-3.amazonaws.com/vectorworks-vcs-test-storage-fr-internal/annazumpalova/s3/Public%20Library%20v2022%20v2023b217.300x300.cf60211c0224c9bcab40d3d283f06462.png",
            "storage_type": "s3",
            "size": "823572",
            "resource_uri": "/restapi/public/v2/s3/file/o:azumpalova/p:Public%20Library%20v2022%20v2023b217.pdf/id:11ed243e025c2f28b91f0eb16aac7caf/v:CH.u5JEHjhRkLgm253CUV_eznkqEbzUn/",
            "download_url": "/restapi/public/v2/s3/file/:download/o:azumpalova/p:Public%20Library%20v2022%20v2023b217.pdf/id:11ed243e025c2f28b91f0eb16aac7caf/v:CH.u5JEHjhRkLgm253CUV_eznkqEbzUn/",
            "exists": true,
            "is_name_valid": true,
            "last_modified": "2022-08-25T06:20:24.000Z",
            "name": "Public Library v2022 v2023b217.pdf",
            "prefix": "Public Library v2022 v2023b217.pdf",
            "previous_versions": [],
            "related": [],
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "file_type": "PDF",
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            }
        },
        {
            "id": 2605237,
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkAQDExZWQyN2RiYTNmNDZmMmI4NDc1MGViMTZhYWM3Y2Fm",
            "thumbnail_3d": "",
            "version_id": "sn20rvt8TiwEL4HZcY42SDPLy760r3Lx",
            "thumbnail": "",
            "storage_type": "s3",
            "size": "3491",
            "resource_uri": "/restapi/public/v2/s3/file/o:azumpalova/p:Room_20220829-234616.8800.mtl/id:11ed27dba3f46f2b84750eb16aac7caf/v:sn20rvt8TiwEL4HZcY42SDPLy760r3Lx/",
            "download_url": "/restapi/public/v2/s3/file/:download/o:azumpalova/p:Room_20220829-234616.8800.mtl/id:11ed27dba3f46f2b84750eb16aac7caf/v:sn20rvt8TiwEL4HZcY42SDPLy760r3Lx/",
            "exists": true,
            "is_name_valid": true,
            "last_modified": "2022-08-29T20:46:22.000Z",
            "name": "Room_20220829-234616.8800.mtl",
            "prefix": "Room_20220829-234616.8800.mtl",
            "previous_versions": [],
            "related": [],
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "file_type": "OTHER",
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            }
        },
        {
            "id": 2605239,
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkAQDExZWQyN2RiYTQxYjgzN2Q4MzUzMGViMTZhYWM3Y2Fm",
            "thumbnail_3d": "",
            "version_id": "rfSGyuq8awP.nhOdV8yA2LpVYMM5bUPD",
            "thumbnail": "",
            "storage_type": "s3",
            "size": "11356",
            "resource_uri": "/restapi/public/v2/s3/file/o:azumpalova/p:Room_20220829-234616.8800.obj/id:11ed27dba41b837d83530eb16aac7caf/v:rfSGyuq8awP.nhOdV8yA2LpVYMM5bUPD/",
            "download_url": "/restapi/public/v2/s3/file/:download/o:azumpalova/p:Room_20220829-234616.8800.obj/id:11ed27dba41b837d83530eb16aac7caf/v:rfSGyuq8awP.nhOdV8yA2LpVYMM5bUPD/",
            "exists": true,
            "is_name_valid": true,
            "last_modified": "2022-08-29T20:46:22.000Z",
            "name": "Room_20220829-234616.8800.obj",
            "prefix": "Room_20220829-234616.8800.obj",
            "previous_versions": [],
            "related": [],
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "file_type": "OTHER",
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            }
        },
        {
            "id": 2605240,
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkAQDExZWQyN2RiYTQyYjY5ZGQ4MzI1MGViMTZhYWM3Y2Fm",
            "thumbnail_3d": "",
            "version_id": "BV_bD2LsRZIvpERNjLnXyq1J.drFZI6h",
            "thumbnail": "",
            "storage_type": "s3",
            "size": "49262",
            "resource_uri": "/restapi/public/v2/s3/file/o:azumpalova/p:Room_20220829-234616.8800.usdz/id:11ed27dba42b69dd83250eb16aac7caf/v:BV_bD2LsRZIvpERNjLnXyq1J.drFZI6h/",
            "download_url": "/restapi/public/v2/s3/file/:download/o:azumpalova/p:Room_20220829-234616.8800.usdz/id:11ed27dba42b69dd83250eb16aac7caf/v:BV_bD2LsRZIvpERNjLnXyq1J.drFZI6h/",
            "exists": true,
            "is_name_valid": true,
            "last_modified": "2022-08-29T20:46:22.000Z",
            "name": "Room_20220829-234616.8800.usdz",
            "prefix": "Room_20220829-234616.8800.usdz",
            "previous_versions": [],
            "related": [],
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "file_type": "OTHER",
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            }
        }
    ],
    "parent": null,
    "subfolders": [
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWM2ZDMxM2ZlOGVlZjBhN2VlMGUxNzM0ODA2Yzc3",
            "storage_type": "s3",
            "name": "GLTF files (adamyanov@nemetschek.bg)",
            "is_name_valid": true,
            "prefix": "GLTF files (adamyanov@nemetschek.bg)/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:GLTF%20files%20(adamyanov@nemetschek.bg)/id:11ec6d313fe8eef0a7ee0e1734806c77/",
            "sharing_info": {
                "is_shared": true,
                "link": "/links/11ec9bbdd4b040609c190efd18abf9e9/",
                "link_uuid": "11ec9bbdd4b040609c190efd18abf9e9",
                "link_expires": "9999-12-31T23:59:59Z",
                "link_visits_count": 0,
                "shared_with": [
                    {
                        "email": "anni97.test@gmail.com",
                        "login": "azumpalovatest2",
                        "username": "Anna Borisova",
                        "permissions": [
                            "modify",
                            "download"
                        ],
                        "has_joined": true
                    }
                ],
                "resource_uri": "/restapi/public/v2/s3/shared_info/o:azumpalova/p:GLTF%20files%20(adamyanov@nemetschek.bg)/id:11ec6d313fe8eef0a7ee0e1734806c77/",
                "last_share_date": "2022-08-23T07:48:06.000Z",
                "allow_comments": true
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhiNmFmZDczNS1lZTY1LTQ1ZmMtYjA0Ni04NTNlYWFmNTU3NDABQDExZWMwMTk3YzAyZWMzZTQ4NzY2MGU5MzI2MDhlNTBi",
            "storage_type": "s3",
            "name": "New folder for Testing",
            "is_name_valid": true,
            "prefix": "New folder for Testing/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:anni97.test@gmail.com/p:New%20folder%20for%20Testing/id:11ec0197c02ec3e487660e932608e50b/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": false,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": true,
                "is_mount_point": true,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "anni97.test@gmail.com",
                "owner_email": "anni97.test@gmail.com",
                "owner_name": "Anna Borisova",
                "upload_prefix": "anni97.test@gmail.com2",
                "owner_region": "de",
                "has_joined": true,
                "permission": [
                    "modify",
                    "download"
                ],
                "date_created": "2022-08-15T11:27:15.000Z",
                "shared_parent_folder": "",
                "mount_point": {
                    "storage_type": "s3",
                    "prefix": "anni97.test@gmail.com2",
                    "path": "New folder for Testing",
                    "mount_path": "New folder for Testing"
                }
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWJmYjQ3NDllMzE3YTE4MjFlMGU3NTBhNDAxYmIy",
            "storage_type": "s3",
            "name": "Panorama",
            "is_name_valid": true,
            "prefix": "Panorama/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:Panorama/id:11ebfb4749e317a1821e0e750a401bb2/",
            "sharing_info": {
                "is_shared": true,
                "link": "/links/11ec2b3d45c64c8aa77d0efaafeadf71/",
                "link_uuid": "11ec2b3d45c64c8aa77d0efaafeadf71",
                "link_expires": "9999-12-31T23:59:59Z",
                "link_visits_count": 0,
                "shared_with": [
                    {
                        "email": "anni97.test@gmail.com",
                        "login": "azumpalovatest2",
                        "username": "Anna Borisova",
                        "permissions": [
                            "modify",
                            "download"
                        ],
                        "has_joined": true
                    }
                ],
                "resource_uri": "/restapi/public/v2/s3/shared_info/o:azumpalova/p:Panorama/id:11ebfb4749e317a1821e0e750a401bb2/",
                "last_share_date": "2022-08-23T10:50:35.000Z",
                "allow_comments": true
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWJmYjQ3NDllZGYzYWI4MjFlMGU3NTBhNDAxYmIy",
            "storage_type": "s3",
            "name": "Reference files",
            "is_name_valid": true,
            "prefix": "Reference files/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:Reference%20files/id:11ebfb4749edf3ab821e0e750a401bb2/",
            "sharing_info": {
                "is_shared": false,
                "link": "/links/11ec8982162233b49b130efd18abf9e9/",
                "link_uuid": "11ec8982162233b49b130efd18abf9e9",
                "link_expires": "9999-12-31T23:59:59Z",
                "link_visits_count": 0,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "2022-08-23T07:48:06.000Z",
                "allow_comments": true
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWJmYjQ3NDllZDFjMGI4MjFlMGU3NTBhNDAxYmIy",
            "storage_type": "s3",
            "name": "Vectorworks files",
            "is_name_valid": true,
            "prefix": "Vectorworks files/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:Vectorworks%20files/id:11ebfb4749ed1c0b821e0e750a401bb2/",
            "sharing_info": {
                "is_shared": true,
                "link": "/links/11ec42c9fc2da3a5ba380efaafeadf71/",
                "link_uuid": "11ec42c9fc2da3a5ba380efaafeadf71",
                "link_expires": "9999-12-31T23:59:59Z",
                "link_visits_count": 0,
                "shared_with": [
                    {
                        "email": "anni97.test@gmail.com",
                        "login": "anni97.test@gmail.com",
                        "username": "Anna Borisova",
                        "permissions": [
                            "modify",
                            "download"
                        ],
                        "has_joined": true
                    }
                ],
                "resource_uri": "/restapi/public/v2/s3/shared_info/o:azumpalova/p:Vectorworks%20files/id:11ebfb4749ed1c0b821e0e750a401bb2/",
                "last_share_date": "2022-08-23T07:48:06.000Z",
                "allow_comments": true
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhiZGVlNTA0Yy01MTU2LTQzMmYtYTgzNS0yM2E4ZWQ1YTliZGQBQDExZWJmYjQ3NGM3MmYzNWE4MjFlMGU3NTBhNDAxYmIy",
            "storage_type": "s3",
            "name": "Shared folder",
            "is_name_valid": true,
            "prefix": "Shared folder/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:adamyanov/p:Shared%20folder/id:11ebfb474c72f35a821e0e750a401bb2/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": false,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": true,
                "is_mount_point": true,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "adamyanov",
                "owner_email": "adamyanov@nemetschek.bg",
                "owner_name": "Asen Damyanov",
                "upload_prefix": "adamyanov",
                "owner_region": "de",
                "has_joined": true,
                "permission": [
                    "modify",
                    "download"
                ],
                "date_created": "2022-04-01T07:54:56.000Z",
                "shared_parent_folder": "",
                "mount_point": {
                    "storage_type": "s3",
                    "prefix": "adamyanov",
                    "path": "Shared folder",
                    "mount_path": "Shared folder"
                }
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhiZGVlNTA0Yy01MTU2LTQzMmYtYTgzNS0yM2E4ZWQ1YTliZGQBQDExZWJmYjQ3NDk4M2I3NzQ4MjFlMGU3NTBhNDAxYmIy",
            "storage_type": "s3",
            "name": "Video",
            "is_name_valid": true,
            "prefix": "Video/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:adamyanov/p:Video/id:11ebfb474983b774821e0e750a401bb2/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": false,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": true,
                "is_mount_point": true,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "adamyanov",
                "owner_email": "adamyanov@nemetschek.bg",
                "owner_name": "Asen Damyanov",
                "upload_prefix": "adamyanov",
                "owner_region": "de",
                "has_joined": true,
                "permission": [
                    "modify",
                    "download"
                ],
                "date_created": "2022-05-05T11:55:49.000Z",
                "shared_parent_folder": "",
                "mount_point": {
                    "storage_type": "s3",
                    "prefix": "adamyanov",
                    "path": "Video",
                    "mount_path": "Video"
                }
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhiZGVlNTA0Yy01MTU2LTQzMmYtYTgzNS0yM2E4ZWQ1YTliZGQBQDExZWJmZmZmNzM0N2I3OGM4NzY2MGU5MzI2MDhlNTBi",
            "storage_type": "s3",
            "name": "ä, ö, ü",
            "is_name_valid": true,
            "prefix": "ä, ö, ü/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:adamyanov/p:%C3%A4,%20%C3%B6,%20%C3%BC/id:11ebffff7347b78c87660e932608e50b/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": false,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": true,
                "is_mount_point": true,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "adamyanov",
                "owner_email": "adamyanov@nemetschek.bg",
                "owner_name": "Asen Damyanov",
                "upload_prefix": "adamyanov",
                "owner_region": "de",
                "has_joined": true,
                "permission": [
                    "modify",
                    "download"
                ],
                "date_created": "2022-05-10T08:16:20.000Z",
                "shared_parent_folder": "",
                "mount_point": {
                    "storage_type": "s3",
                    "prefix": "adamyanov",
                    "path": "ä, ö, ü",
                    "mount_path": "ä, ö, ü"
                }
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWQyMjEwYjQ0NjJhOWE4N2Y3MGViMTZhYWM3Y2Fm",
            "storage_type": "s3",
            "name": "2021 Test",
            "is_name_valid": true,
            "prefix": "2021 Test/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:2021%20Test/id:11ed2210b4462a9a87f70eb16aac7caf/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWQyMWY4MWZmNGViNmI4MTAwMGViMTZhYWM3Y2Fm",
            "storage_type": "s3",
            "name": "2022 - job testing",
            "is_name_valid": true,
            "prefix": "2022 - job testing/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:2022%20-%20job%20testing/id:11ed21f81ff4eb6b81000eb16aac7caf/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWQxN2Q5OGFlMjVkYzZiYmZlMGViMTZhYWM3Y2Fm",
            "storage_type": "s3",
            "name": "2023-2",
            "is_name_valid": true,
            "prefix": "2023-2/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:2023-2/id:11ed17d98ae25dc6bbfe0eb16aac7caf/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWQwYmY2MWZlMGJiODJhZDA4MGViMTZhYWM3Y2Fm",
            "storage_type": "s3",
            "name": "2023",
            "is_name_valid": true,
            "prefix": "2023/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:2023/id:11ed0bf61fe0bb82ad080eb16aac7caf/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWQxZWZiNGRkODM4ODE4MWMzMGViMTZhYWM3Y2Fm",
            "storage_type": "s3",
            "name": "Photogrammetry",
            "is_name_valid": true,
            "prefix": "Photogrammetry/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:Photogrammetry/id:11ed1efb4dd8388181c30eb16aac7caf/",
            "sharing_info": {
                "is_shared": true,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [
                    {
                        "email": "LHadzhipopov@vectorworks.net",
                        "login": "lhadzhipopov",
                        "username": "Lyuben Hadzhipopov",
                        "permissions": [
                            "modify",
                            "download"
                        ],
                        "has_joined": true
                    }
                ],
                "resource_uri": "/restapi/public/v2/s3/shared_info/o:azumpalova/p:Photogrammetry/id:11ed1efb4dd8388181c30eb16aac7caf/",
                "last_share_date": "2022-08-19T06:46:52.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWQxYzc4N2JiZjAyYmRiOTJjMGViMTZhYWM3Y2Fm",
            "storage_type": "s3",
            "name": "Sync folder",
            "is_name_valid": true,
            "prefix": "Sync folder/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:Sync%20folder/id:11ed1c787bbf02bdb92c0eb16aac7caf/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWQxYzlhOWYwZjQ0ZTY4M2QyMGViMTZhYWM3Y2Fm",
            "storage_type": "s3",
            "name": "nomad2",
            "is_name_valid": true,
            "prefix": "nomad2/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:nomad2/id:11ed1c9a9f0f44e683d20eb16aac7caf/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "Akg4NDE0YTAwNS1mYmI3LTU3YmItYWYzYi02ZGY4MmJkYjM5YTcBQDExZWNmOTM1ZjlkNjAzMWY4MGM3MGViMTZhYWM3Y2Fm",
            "storage_type": "s3",
            "name": "☢️☢️☢️",
            "is_name_valid": true,
            "prefix": "☢️☢️☢️/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:vkolova/p:%E2%98%A2%EF%B8%8F%E2%98%A2%EF%B8%8F%E2%98%A2%EF%B8%8F/id:11ecf935f9d6031f80c70eb16aac7caf/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": false,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": true,
                "is_mount_point": true,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "vkolova",
                "owner_email": "vkolova@vectorworks.net",
                "owner_name": "Veselina Kolova",
                "upload_prefix": "vkolova",
                "owner_region": "au",
                "has_joined": true,
                "permission": [
                    "modify",
                    "download"
                ],
                "date_created": "2022-08-01T10:06:07.000Z",
                "shared_parent_folder": "",
                "mount_point": {
                    "storage_type": "s3",
                    "prefix": "vkolova",
                    "path": "☢️☢️☢️",
                    "mount_path": "☢️☢️☢️"
                }
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWQyNDQzNWFjNTUzNGRiMDYyMGViMTZhYWM3Y2Fm",
            "storage_type": "s3",
            "name": "nomad3",
            "is_name_valid": true,
            "prefix": "nomad3/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:nomad3/id:11ed24435ac5534db0620eb16aac7caf/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWQyNTFhZWZmYjYzYWViMzRmMGViMTZhYWM3Y2Fm",
            "storage_type": "s3",
            "name": "test heic",
            "is_name_valid": true,
            "prefix": "test heic/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:test%20heic/id:11ed251aeffb63aeb34f0eb16aac7caf/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWQyNzhhNTFhZWI4MDFhNjJjMGViMTZhYWM3Y2Fm",
            "storage_type": "s3",
            "name": "photogrammetry new",
            "is_name_valid": true,
            "prefix": "photogrammetry new/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:photogrammetry%20new/id:11ed278a51aeb801a62c0eb16aac7caf/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWQyNzhiN2RiMmFhZTU5NmM4MGViMTZhYWM3Y2Fm",
            "storage_type": "s3",
            "name": "photo 1",
            "is_name_valid": true,
            "prefix": "photo 1/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:photo%201/id:11ed278b7db2aae596c80eb16aac7caf/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        },
        {
            "resource_id": "AkhkMTQ3Yjk1MS03NTFmLTRlYWEtOWIyYy1hOWZkMTU5NjMyZjkBQDExZWQyNzhmZTg4NWUxNDE4ZDQxMGViMTZhYWM3Y2Fm",
            "storage_type": "s3",
            "name": "Apple photogrammetry",
            "is_name_valid": true,
            "prefix": "Apple photogrammetry/",
            "exists": true,
            "resource_uri": "/restapi/public/v2/s3/folder/o:azumpalova/p:Apple%20photogrammetry/id:11ed278fe885e1418d410eb16aac7caf/",
            "sharing_info": {
                "is_shared": false,
                "link": null,
                "link_uuid": null,
                "link_expires": null,
                "link_visits_count": null,
                "shared_with": [],
                "resource_uri": "",
                "last_share_date": "1970-01-01T05:00:00.000Z",
                "allow_comments": null
            },
            "flags": {
                "is_supported": true,
                "is_name_valid": true,
                "is_file_type_supported": true,
                "is_name_duplicate": false,
                "is_mounted": false,
                "is_mount_point": false,
                "is_google_trashable": true
            },
            "owner_info": {
                "owner": "azumpalova",
                "owner_email": "azumpalova@vectorworks.net",
                "owner_name": "Anna Zumpalova",
                "upload_prefix": "annazumpalova",
                "owner_region": "fr",
                "has_joined": false,
                "permission": [],
                "date_created": null,
                "shared_parent_folder": "",
                "mount_point": null
            },
            "files": [],
            "parent": "/restapi/public/v2/s3/folder/o:azumpalova/",
            "subfolders": [],
            "autoprocess_parent": "/"
        }
    ],
    "autoprocess_parent": "/"
}
"""
}
