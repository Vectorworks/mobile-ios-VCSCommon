import Foundation

public class VCSFolderResponse: Asset, Codable {
    
    public static var addToCacheRootFolderID: String?
    
    
    private(set) public var isFolder = true
    private(set) public var isFile = false
    
    public var VCSID: String
    
    public var resourceURI: String = ""
    public var resourceID: String = ""
    public var exists: Bool = false
    public var isNameValid: Bool = false
    public var name: String = ""
    public var prefix: String = ""
    
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
    public var storageTypeString: String { return self.storageType.rawValue }
    public var storageTypeDisplayString: String { return self.storageType.displayName }
    
    private(set) public var ownerLogin: String
    public func updateSharedOwnerLogin(_ login: String) {
        self.subfolders.forEach { $0.updateSharedOwnerLogin(login) }
        self.files.forEach { $0.updateSharedOwnerLogin(login) }
        self.ownerLogin = login
    }
    
    public let parent: String?
    public let autoprocessParent: String?
    
    private(set) public var files: [VCSFileResponse]
    private(set) public var subfolders: [VCSFolderResponse]
    
    public func appendFile(_ file: VCSFileResponse) {
        self.files.append(file)
        VCSCache.addToCache(item: self)
    }
    
    public func removeFile(_ file: VCSFileResponse) {
        if let index = self.files.firstIndex(of: file) {
            self.files.remove(at: index)
        }
        VCSCache.addToCache(item: self)
    }
    
    public func appendShallowFolder(_ folder: VCSFolderResponse) {
        self.subfolders.append(folder)
        VCSCache.addToCache(item: self)
    }
    
    public func removeFolder(_ folder: VCSFolderResponse) {
        if let index = self.subfolders.firstIndex(of: folder) {
            self.subfolders.remove(at: index)
        }
        VCSCache.addToCache(item: self)
    }
    
    public var cachedFiles: [VCSFileResponse]? { return self.files.filter { return $0.isAvailableOnDevice } }
    
    public func loadLocalFiles() {
        self.subfolders.forEach {
            $0.loadLocalFiles()
        }
        self.files.forEach {
            $0.loadLocalFiles()
        }
    }
    
    public func updateSharingInfo(other: VCSSharingInfoResponse) {
        self.sharingInfo = other
        VCSCache.addToCache(item: self, forceNilValuesUpdate: true)
    }

    public lazy var sortingDate: Date = { return Date() }()
    
    public var realStorage: String { return self.ownerInfo?.mountPoint?.storageType.rawValue ?? self.storageType.rawValue }
    public var realPrefix: String {
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
        self.files = (try? container.decode([VCSFileResponse].self, forKey: CodingKeys.files)) ?? []
        self.parent = try? container.decode(String.self, forKey: CodingKeys.parent)
        self.subfolders = (try? container.decode([VCSFolderResponse].self, forKey: CodingKeys.subfolders)) ?? []
        self.autoprocessParent = try? container.decode(String.self, forKey: CodingKeys.autoprocessParent)
        
        self.ownerLogin = self.ownerInfo?.owner ?? VCSUser.savedUser?.login ?? ""
        
        if self.resourceID == "__invalid__",
           self.name == "" {
            self.resourceID = self.storageType.itemIdentifier.appendingPathComponent(self.prefix)
        }
        
        self.VCSID = self.resourceID
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
    
    public init(files: [VCSFileResponse],
                parent: String?,
                subfolders: [VCSFolderResponse],
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
        return self.files.contains { return $0.isAvailableOnDevice }
            || self.subfolders.contains { return $0.isAvailableOnDevice }
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
    public static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
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
    
    public func deleteFromCache() {
        VCSFolderResponse.realmStorage.delete(item: self)
    }
}

public extension VCSFolderResponse {
    var isGoogleOrOneDriveFolder: Bool {
        return VCSFolderResponse.isGoogleOrOneDriveFolder(self.storageTypeString)
    }
    
    static func isGoogleOrOneDriveFolder(_ storageType: String) -> Bool {
        return storageType == StorageType.GOOGLE_DRIVE.rawValue || storageType == StorageType.ONE_DRIVE.rawValue
    }
    
//    var isSharedWithMeGoogleOrOneDriveFolder: Bool {
//        return VCSFolderResponse.isPrefixSharedWithMeGoogleOrOneDriveFolder(self.prefix, storageType: self.storageTypeString)
//    }
//    
//    static func isPrefixSharedWithMeGoogleOrOneDriveFolder(_ prefix: String, storageType: String) -> Bool {
//        let isGoogleDriveSharedWithMe = prefix.range(of: StoragePage.driveIDSharedRegXPattern, options:.regularExpression) != nil
//        
//        var isOneDriveSharedWithMe = false
//        if storageType == StorageType.ONE_DRIVE.rawValue, let oneDriveRootPrefix = VCSUser.savedUser?.availableStorages.first(where: { $0.storageType == StorageType.ONE_DRIVE })?.pages.first(where: { $0.name == "My Files" })?.id {
//            isOneDriveSharedWithMe = prefix.range(of: oneDriveRootPrefix , options:.regularExpression) == nil
//        }
//        
//        return isGoogleDriveSharedWithMe || isOneDriveSharedWithMe
//    }
}

extension VCSFolderResponse: Hashable {
    public static func == (lhs: VCSFolderResponse, rhs: VCSFolderResponse) -> Bool {
        return lhs.VCSID == rhs.VCSID
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(VCSID)
    }
}

public extension VCSFolderResponse {
    static var nilFolder = VCSFolderResponse(files: [], parent: nil, subfolders: [], autoprocessParent: nil, resourceURI: "", resourceID: "", exists: false, isNameValid: false, name: "", prefix: "", storageType: .S3, ownerLogin: "", VCSID: "")
    static var testVCSFolder: VCSFolderResponse? = { return try? JSONDecoder().decode(VCSFolderResponse.self, from: VCSFolderResponse.testFolderJSONString.data(using: .utf8)!) }()
    
    static var testFolderJSONString = """
{
  "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQBQDExZWNmM2I1NTU3YmE1Njk4MGUzMGViMTZhYWM3Y2Fm",
  "storage_type": "s3",
  "name": "00",
  "is_name_valid": true,
  "prefix": "00/",
  "exists": true,
  "resource_uri": "/restapi/public/v2/s3/folder/o:iiliev/p:00/id:11ecf3b5557ba56980e30eb16aac7caf/",
  "sharing_info": {
    "is_shared": false,
    "link": "/links/11ee376b15b1de05a0620e21e8464157/",
    "link_uuid": "11ee376b15b1de05a0620e21e8464157",
    "link_expires": "9999-12-31T23:59:59Z",
    "link_visits_count": 0,
    "shared_with": [],
    "resource_uri": "",
    "last_share_date": "2023-08-10T10:45:56.000Z",
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
    "owner": "iiliev",
    "owner_email": "iiliev@nemetschek.bg",
    "owner_name": "Ivaylo Iliev",
    "upload_prefix": "iiliev",
    "owner_region": "de",
    "has_joined": false,
    "permission": [],
    "date_created": null,
    "shared_parent_folder": "",
    "mount_point": null
  },
  "files": [
    {
      "id": 5007218,
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQAQDExZWRjMjQ4ZjgyZDI5MTQ5ZWFhMGViN2ZmYjM5MGFm",
      "thumbnail_3d": "",
      "version_id": "fXkW6aMNhiYQYrzlS22CZaCuwWykPa_K",
      "thumbnail": "https://s3.eu-central-1.amazonaws.com/vectorworks-vcs-test-storage-de-internal/iiliev/s3/00/1.300x300.7202b29235c39db489fffc1368fc4e9a.png",
      "storage_type": "s3",
      "size": "116000",
      "resource_uri": "/restapi/public/v2/s3/file/o:iiliev/p:00/1.pdf/id:11edc248f82d29149eaa0eb7ffb390af/v:fXkW6aMNhiYQYrzlS22CZaCuwWykPa_K/",
      "download_url": "/restapi/public/v2/s3/file/:download/o:iiliev/p:00/1.pdf/id:11edc248f82d29149eaa0eb7ffb390af/v:fXkW6aMNhiYQYrzlS22CZaCuwWykPa_K/",
      "exists": true,
      "is_name_valid": true,
      "last_modified": "2024-04-26T12:20:30.000Z",
      "name": "1.pdf",
      "prefix": "00/1.pdf",
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
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      }
    },
    {
      "id": 5300960,
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQAQDExZWRjMjRhNWM4ODA0NWFiZjVmMGViN2ZmYjM5MGFm",
      "thumbnail_3d": "",
      "version_id": "goH7ZqhDVXepxvAI6As6wJBVmRWGIqnd",
      "thumbnail": "https://s3.eu-central-1.amazonaws.com/vectorworks-vcs-test-storage-de-internal/iiliev/s3/00/1_markup.300x300.6bb0d0bdc371e64c5fcd2456ded1442d.png",
      "storage_type": "s3",
      "size": "174275",
      "resource_uri": "/restapi/public/v2/s3/file/o:iiliev/p:00/1_markup.pdf/id:11edc24a5c88045abf5f0eb7ffb390af/v:goH7ZqhDVXepxvAI6As6wJBVmRWGIqnd/",
      "download_url": "/restapi/public/v2/s3/file/:download/o:iiliev/p:00/1_markup.pdf/id:11edc24a5c88045abf5f0eb7ffb390af/v:goH7ZqhDVXepxvAI6As6wJBVmRWGIqnd/",
      "exists": true,
      "is_name_valid": true,
      "last_modified": "2024-07-15T13:25:19.000Z",
      "name": "1_markup.pdf",
      "prefix": "00/1_markup.pdf",
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
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      }
    },
    {
      "id": 4745190,
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQAQDExZWVjOThhMjJlMGZhMjFiZDkyMGUwOTZlMGI3ZDdi",
      "thumbnail_3d": "",
      "version_id": "lQnJzS7SpUF7LHw0YcVMKCCKgm2wM7NP",
      "thumbnail": "",
      "storage_type": "s3",
      "size": "11465259",
      "resource_uri": "/restapi/public/v2/s3/file/o:iiliev/p:00/toy_biplane_idle.usdz/id:11eec98a22e0fa21bd920e096e0b7d7b/v:lQnJzS7SpUF7LHw0YcVMKCCKgm2wM7NP/",
      "download_url": "/restapi/public/v2/s3/file/:download/o:iiliev/p:00/toy_biplane_idle.usdz/id:11eec98a22e0fa21bd920e096e0b7d7b/v:lQnJzS7SpUF7LHw0YcVMKCCKgm2wM7NP/",
      "exists": true,
      "is_name_valid": true,
      "last_modified": "2024-02-12T09:33:46.000Z",
      "name": "toy_biplane_idle.usdz",
      "prefix": "00/toy_biplane_idle.usdz",
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
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      }
    },
    {
      "id": 5052643,
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQAQDExZWYwZGYwZGJlYmVkYjY4OTg0MGUwOTZlMGI3ZDdi",
      "thumbnail_3d": "",
      "version_id": "6BO8OWymo61_tkXpNn.TxL1qRLp1Z1rQ",
      "thumbnail": "",
      "storage_type": "s3",
      "size": "52428800",
      "resource_uri": "/restapi/public/v2/s3/file/o:iiliev/p:00/50MB%20copy.png/id:11ef0df0dbebedb689840e096e0b7d7b/v:6BO8OWymo61_tkXpNn.TxL1qRLp1Z1rQ/",
      "download_url": "/restapi/public/v2/s3/file/:download/o:iiliev/p:00/50MB%20copy.png/id:11ef0df0dbebedb689840e096e0b7d7b/v:6BO8OWymo61_tkXpNn.TxL1qRLp1Z1rQ/",
      "exists": true,
      "is_name_valid": true,
      "last_modified": "2024-05-09T10:42:35.000Z",
      "name": "50MB copy.png",
      "prefix": "00/50MB copy.png",
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
      "file_type": "IMG",
      "owner_info": {
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      }
    },
    {
      "id": 5212623,
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQAQDExZWYyZDdhNmU4MTk3MzBiMDk3MGFmZmMxNDdlZmM5",
      "thumbnail_3d": "",
      "version_id": "bR9jEoKLwkDHPJC_xME1uZU6sYlv9BJW",
      "thumbnail": "",
      "storage_type": "s3",
      "size": "2",
      "resource_uri": "/restapi/public/v2/s3/file/o:iiliev/p:00/Heey.pts/id:11ef2d7a6e819730b0970affc147efc9/v:bR9jEoKLwkDHPJC_xME1uZU6sYlv9BJW/",
      "download_url": "/restapi/public/v2/s3/file/:download/o:iiliev/p:00/Heey.pts/id:11ef2d7a6e819730b0970affc147efc9/v:bR9jEoKLwkDHPJC_xME1uZU6sYlv9BJW/",
      "exists": true,
      "is_name_valid": true,
      "last_modified": "2024-06-18T13:55:33.000Z",
      "name": "Heey.pts",
      "prefix": "00/Heey.pts",
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
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      }
    },
    {
      "id": 5212624,
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQAQDExZWYyZDdhNzYwYjRiMmM5ZmMxMGViNjU3YzFiOTMx",
      "thumbnail_3d": "",
      "version_id": "xRkCHvuO4PA8mkXLl8v.Mjpu9bC7XfKp",
      "thumbnail": "",
      "storage_type": "s3",
      "size": "880566",
      "resource_uri": "/restapi/public/v2/s3/file/o:iiliev/p:00/bunnyData.pts/id:11ef2d7a760b4b2c9fc10eb657c1b931/v:xRkCHvuO4PA8mkXLl8v.Mjpu9bC7XfKp/",
      "download_url": "/restapi/public/v2/s3/file/:download/o:iiliev/p:00/bunnyData.pts/id:11ef2d7a760b4b2c9fc10eb657c1b931/v:xRkCHvuO4PA8mkXLl8v.Mjpu9bC7XfKp/",
      "exists": true,
      "is_name_valid": true,
      "last_modified": "2024-06-18T13:55:44.000Z",
      "name": "bunnyData.pts",
      "prefix": "00/bunnyData.pts",
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
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      }
    },
    {
      "id": 5212625,
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQAQDExZWYyZDdhODIwN2JiYzJiMDk3MGFmZmMxNDdlZmM5",
      "thumbnail_3d": "",
      "version_id": "U1urPpsJ2p7S1tl7LGSJiFsArDWZu0xI",
      "thumbnail": "",
      "storage_type": "s3",
      "size": "8951227",
      "resource_uri": "/restapi/public/v2/s3/file/o:iiliev/p:00/TV.pts/id:11ef2d7a8207bbc2b0970affc147efc9/v:U1urPpsJ2p7S1tl7LGSJiFsArDWZu0xI/",
      "download_url": "/restapi/public/v2/s3/file/:download/o:iiliev/p:00/TV.pts/id:11ef2d7a8207bbc2b0970affc147efc9/v:U1urPpsJ2p7S1tl7LGSJiFsArDWZu0xI/",
      "exists": true,
      "is_name_valid": true,
      "last_modified": "2024-06-18T13:55:35.000Z",
      "name": "TV.pts",
      "prefix": "00/TV.pts",
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
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      }
    },
    {
      "id": 5246771,
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQAQDExZWYzNTMyODU0OTdjN2E4NzljMGFmZmMxNDdlZmM5",
      "thumbnail_3d": "",
      "version_id": "5AlG8S7GY8XxTGA3GzpP5.tj2uhV6US3",
      "thumbnail": "https://s3.eu-central-1.amazonaws.com/vectorworks-vcs-test-storage-de-internal/iiliev/s3/00/pexels-eberhardgross-1670187.300x300.d4e790929f30292f98696c4bb11fb0a5.png",
      "storage_type": "s3",
      "size": "2277050",
      "resource_uri": "/restapi/public/v2/s3/file/o:iiliev/p:00/pexels-eberhardgross-1670187.jpg/id:11ef353285497c7a879c0affc147efc9/v:5AlG8S7GY8XxTGA3GzpP5.tj2uhV6US3/",
      "download_url": "/restapi/public/v2/s3/file/:download/o:iiliev/p:00/pexels-eberhardgross-1670187.jpg/id:11ef353285497c7a879c0affc147efc9/v:5AlG8S7GY8XxTGA3GzpP5.tj2uhV6US3/",
      "exists": true,
      "is_name_valid": true,
      "last_modified": "2024-06-28T09:40:57.000Z",
      "name": "pexels-eberhardgross-1670187.jpg",
      "prefix": "00/pexels-eberhardgross-1670187.jpg",
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
      "file_type": "IMG",
      "owner_info": {
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      }
    },
    {
      "id": 5246772,
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQAQDExZWYzNTMyODYxMTAzOTQ4OGM1MGFmZmMxNDdlZmM5",
      "thumbnail_3d": "",
      "version_id": "nCvffD2qoTDyGcF3_mwa4OoRpuyZ9VUm",
      "thumbnail": "https://s3.eu-central-1.amazonaws.com/vectorworks-vcs-test-storage-de-internal/iiliev/s3/00/pexels-mia-stein-3894157.300x300.b9a9bd179cbda649102112fde2360dae.png",
      "storage_type": "s3",
      "size": "1738152",
      "resource_uri": "/restapi/public/v2/s3/file/o:iiliev/p:00/pexels-mia-stein-3894157.jpg/id:11ef35328611039488c50affc147efc9/v:nCvffD2qoTDyGcF3_mwa4OoRpuyZ9VUm/",
      "download_url": "/restapi/public/v2/s3/file/:download/o:iiliev/p:00/pexels-mia-stein-3894157.jpg/id:11ef35328611039488c50affc147efc9/v:nCvffD2qoTDyGcF3_mwa4OoRpuyZ9VUm/",
      "exists": true,
      "is_name_valid": true,
      "last_modified": "2024-06-28T09:40:58.000Z",
      "name": "pexels-mia-stein-3894157.jpg",
      "prefix": "00/pexels-mia-stein-3894157.jpg",
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
      "file_type": "IMG",
      "owner_info": {
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      }
    },
    {
      "id": 5246773,
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQAQDExZWYzNTMyODY2NzU1NTA4NzljMGFmZmMxNDdlZmM5",
      "thumbnail_3d": "",
      "version_id": "o5FXCd.PZLVS22EjFnRgmEeYpdaFahwM",
      "thumbnail": "https://s3.eu-central-1.amazonaws.com/vectorworks-vcs-test-storage-de-internal/iiliev/s3/00/pexels-eberhardgross-1366919.300x300.9194fdcbeebcfc2854992da0d7255ae4.png",
      "storage_type": "s3",
      "size": "1091887",
      "resource_uri": "/restapi/public/v2/s3/file/o:iiliev/p:00/pexels-eberhardgross-1366919.jpg/id:11ef353286675550879c0affc147efc9/v:o5FXCd.PZLVS22EjFnRgmEeYpdaFahwM/",
      "download_url": "/restapi/public/v2/s3/file/:download/o:iiliev/p:00/pexels-eberhardgross-1366919.jpg/id:11ef353286675550879c0affc147efc9/v:o5FXCd.PZLVS22EjFnRgmEeYpdaFahwM/",
      "exists": true,
      "is_name_valid": true,
      "last_modified": "2024-06-28T09:40:59.000Z",
      "name": "pexels-eberhardgross-1366919.jpg",
      "prefix": "00/pexels-eberhardgross-1366919.jpg",
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
      "file_type": "IMG",
      "owner_info": {
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      }
    },
    {
      "id": 5246774,
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQAQDExZWYzNTMyODdhN2Q5ZWU4OGM1MGFmZmMxNDdlZmM5",
      "thumbnail_3d": "",
      "version_id": "TbqBe2YUybTFgVGJBw.sLkF_NJazHLM9",
      "thumbnail": "https://s3.eu-central-1.amazonaws.com/vectorworks-vcs-test-storage-de-internal/iiliev/s3/00/pexels-eberhardgross-1624496.300x300.3308ceb2622e5bd6f762d17ee6e1b0c2.png",
      "storage_type": "s3",
      "size": "2037862",
      "resource_uri": "/restapi/public/v2/s3/file/o:iiliev/p:00/pexels-eberhardgross-1624496.jpg/id:11ef353287a7d9ee88c50affc147efc9/v:TbqBe2YUybTFgVGJBw.sLkF_NJazHLM9/",
      "download_url": "/restapi/public/v2/s3/file/:download/o:iiliev/p:00/pexels-eberhardgross-1624496.jpg/id:11ef353287a7d9ee88c50affc147efc9/v:TbqBe2YUybTFgVGJBw.sLkF_NJazHLM9/",
      "exists": true,
      "is_name_valid": true,
      "last_modified": "2024-06-28T09:41:01.000Z",
      "name": "pexels-eberhardgross-1624496.jpg",
      "prefix": "00/pexels-eberhardgross-1624496.jpg",
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
      "file_type": "IMG",
      "owner_info": {
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      }
    },
    {
      "id": 5271238,
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQAQDExZWYzYTlmMjVjNWQ1MDZiYjUwMGFmZmMxNDdlZmM5",
      "thumbnail_3d": "",
      "version_id": "j1OGe.iE7JV_YxddztF1Id1QakK2FElD",
      "thumbnail": "https://s3.eu-central-1.amazonaws.com/vectorworks-vcs-test-storage-de-internal/iiliev/s3/00/1_markup_asd_dsa.300x300.063686a1200c05e1eb24a23e244cc478.png",
      "storage_type": "s3",
      "size": "258718",
      "resource_uri": "/restapi/public/v2/s3/file/o:iiliev/p:00/1_markup_asd_dsa.pdf/id:11ef3a9f25c5d506bb500affc147efc9/v:j1OGe.iE7JV_YxddztF1Id1QakK2FElD/",
      "download_url": "/restapi/public/v2/s3/file/:download/o:iiliev/p:00/1_markup_asd_dsa.pdf/id:11ef3a9f25c5d506bb500affc147efc9/v:j1OGe.iE7JV_YxddztF1Id1QakK2FElD/",
      "exists": true,
      "is_name_valid": true,
      "last_modified": "2024-07-05T07:21:08.000Z",
      "name": "1_markup_asd_dsa.pdf",
      "prefix": "00/1_markup_asd_dsa.pdf",
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
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      }
    },
    {
      "id": 5286280,
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQAQDExZWYzZGVmODhmYmE4OGM4NjExMGFmZmMxNDdlZmM5",
      "thumbnail_3d": "",
      "version_id": "LdJ8T_QtOS5XX.r6.19SQN8EUeEC6NpP",
      "thumbnail": "https://s3.eu-central-1.amazonaws.com/vectorworks-vcs-test-storage-de-internal/iiliev/s3/00/1.300x300.7202b29235c39db489fffc1368fc4e9a.png",
      "storage_type": "s3",
      "size": "116000",
      "resource_uri": "/restapi/public/v2/s3/file/o:iiliev/p:00/1.vcdoc/id:11ef3def88fba88c86110affc147efc9/v:LdJ8T_QtOS5XX.r6.19SQN8EUeEC6NpP/",
      "download_url": "/restapi/public/v2/s3/file/:download/o:iiliev/p:00/1.vcdoc/id:11ef3def88fba88c86110affc147efc9/v:LdJ8T_QtOS5XX.r6.19SQN8EUeEC6NpP/",
      "exists": true,
      "is_name_valid": true,
      "last_modified": "2024-07-09T12:34:08.000Z",
      "name": "1.vcdoc",
      "prefix": "00/1.vcdoc",
      "previous_versions": [],
      "related": [],
      "sharing_info": {
        "is_shared": false,
        "link": "/links/2TLbquqfwCmAFbE2/",
        "link_uuid": "2TLbquqfwCmAFbE2",
        "link_expires": "9999-12-31T23:59:59Z",
        "link_visits_count": 2,
        "shared_with": [],
        "resource_uri": "",
        "last_share_date": "2024-08-08T09:30:44.000Z",
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
      "file_type": "VCDOC",
      "owner_info": {
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      }
    },
    {
      "id": 5306648,
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQAQDExZWY0NDE5YjgyN2M1ZGU4NTYzMGFmZmMxNDdlZmM5",
      "thumbnail_3d": "",
      "version_id": "3e4u9zlK6qAU.k5GXtOtO4wcHFeMX229",
      "thumbnail": "https://s3.eu-central-1.amazonaws.com/vectorworks-vcs-test-storage-de-internal/iiliev/s3/00/1_markup_1.300x300.d44bc4bd253f9bfb477e883e4840caf2.png",
      "storage_type": "s3",
      "size": "212009",
      "resource_uri": "/restapi/public/v2/s3/file/o:iiliev/p:00/1_markup_1.pdf/id:11ef4419b827c5de85630affc147efc9/v:3e4u9zlK6qAU.k5GXtOtO4wcHFeMX229/",
      "download_url": "/restapi/public/v2/s3/file/:download/o:iiliev/p:00/1_markup_1.pdf/id:11ef4419b827c5de85630affc147efc9/v:3e4u9zlK6qAU.k5GXtOtO4wcHFeMX229/",
      "exists": true,
      "is_name_valid": true,
      "last_modified": "2024-07-17T08:51:12.000Z",
      "name": "1_markup_1.pdf",
      "prefix": "00/1_markup_1.pdf",
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
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      }
    }
  ],
  "parent": "/restapi/public/v2/s3/folder/o:iiliev/",
  "subfolders": [
    {
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQBQDExZWU1MTQ0MDBmOTE1OGQ4MmUyMTJiNzg0MGViOTlk",
      "storage_type": "s3",
      "name": "1",
      "is_name_valid": true,
      "prefix": "00/1/",
      "exists": true,
      "resource_uri": "/restapi/public/v2/s3/folder/o:iiliev/p:00/1/id:11ee514400f9158d82e212b7840eb99d/",
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
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      },
      "files": [],
      "parent": "/restapi/public/v2/s3/folder/o:iiliev/p:00/",
      "subfolders": [],
      "autoprocess_parent": "/"
    },
    {
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQBQDExZWYwYzcyZTQwMWYwN2Y4ZGVlMGUwOTZlMGI3ZDdi",
      "storage_type": "s3",
      "name": "2",
      "is_name_valid": true,
      "prefix": "00/2/",
      "exists": true,
      "resource_uri": "/restapi/public/v2/s3/folder/o:iiliev/p:00/2/id:11ef0c72e401f07f8dee0e096e0b7d7b/",
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
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      },
      "files": [],
      "parent": "/restapi/public/v2/s3/folder/o:iiliev/p:00/",
      "subfolders": [],
      "autoprocess_parent": "/"
    },
    {
      "resource_id": "Akg5MGNlZmU1Zi1hZDM4LTQ5YmUtYmI0Yi00YjI4NGQwMDY1ZmQBQDExZWYwYzczMTk3ZTEyYTA4ZGEzMGUwOTZlMGI3ZDdi",
      "storage_type": "s3",
      "name": "3",
      "is_name_valid": true,
      "prefix": "00/3/",
      "exists": true,
      "resource_uri": "/restapi/public/v2/s3/folder/o:iiliev/p:00/3/id:11ef0c73197e12a08da30e096e0b7d7b/",
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
        "owner": "iiliev",
        "owner_email": "iiliev@nemetschek.bg",
        "owner_name": "Ivaylo Iliev",
        "upload_prefix": "iiliev",
        "owner_region": "de",
        "has_joined": false,
        "permission": [],
        "date_created": null,
        "shared_parent_folder": "",
        "mount_point": null
      },
      "files": [],
      "parent": "/restapi/public/v2/s3/folder/o:iiliev/p:00/",
      "subfolders": [],
      "autoprocess_parent": "/"
    }
  ],
  "autoprocess_parent": "/"
}
"""
}
