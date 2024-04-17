import Foundation

public typealias StorageList = [VCSStorageResponse]

public class VCSUserResponse: NSObject, Codable {
    public let meta: Meta
    public let objects: [VCSUser]
}

public class Meta: NSObject, Codable {
    public let limit: Int
    public let next: String?
    public let offset: Int
    public let previous: String?
    public let totalCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case limit, next, offset, previous
        case totalCount = "total_count"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.limit = try container.decode(Int.self, forKey: CodingKeys.limit)
        self.next = try? container.decode(String.self, forKey: CodingKeys.next)
        self.offset = try container.decode(Int.self, forKey: CodingKeys.offset)
        self.previous = try? container.decode(String.self, forKey: CodingKeys.previous)
        self.totalCount = try container.decode(Int.self, forKey: CodingKeys.totalCount)
        super.init()
    }
}

@objc public class VCSUser: NSObject, Codable {
    public let allowedLanguages: String
    public let awskeys: VCSAWSkeys
    @objc public let email, firstName: String
    public let groups: [String]
    @objc public let isVSS: Bool
    @objc public let language, lastName, login, nvwuid: String
    public let preferences: String?
    public let quotas: Quotas
    public let resourceURI, username: String
    public var availableStorages: StorageList { return self.storages }
    internal var storages: StorageList = []
    private(set) public var isLoggedIn: Bool = false
    
    public func addAvailableStorage(storage: VCSStorageResponse) {
        guard !self.storages.contains(storage) else { return }
        self.storages.append(storage)
        VCSCache.addToCache(item: self)
    }
    
    public func setStorageList(storages: StorageList) {
        self.storages.removeAll()
        storages.forEach { (storage: VCSStorageResponse) in
            storage.loadLocalPagesList()
        }
        self.storages.append(contentsOf: storages)
        VCSCache.addToCache(item: self)
    }
    
    public func removeAvailableStorage(storage: VCSStorageResponse) {
        guard self.storages.contains(storage),
            let index = self.storages.firstIndex(of: storage) else { return }
        
        self.storages.remove(at: index)
        VCSCache.addToCache(item: self)
    }
    
    public func removeAvailableStorage(storageType: StorageType) {
        guard let index = self.storages.firstIndex(where: { $0.storageType == storageType }) else { return }
        
        self.storages.remove(at: index)
        VCSCache.addToCache(item: self)
    }
    
    public func updateIsLoggedIn(_ value: Bool) {
        defer { VCSCache.addToCache(item: self) }
        
        self.isLoggedIn = value
    }
    
    
    init(allowedLanguages: String, awskeys: VCSAWSkeys, email: String, firstName: String, groups: [String], isVSS: Bool, language: String, lastName: String, login: String, nvwuid: String, preferences: String?, quotas: Quotas, resourceURI: String, username: String, storages: StorageList, isLoggedIn: Bool) {
        self.allowedLanguages = allowedLanguages
        self.awskeys = awskeys
        self.email = email
        self.firstName = firstName
        self.groups = groups
        self.isVSS = isVSS
        self.language = language
        self.lastName = lastName
        self.login = login
        self.nvwuid = nvwuid
        self.preferences = preferences
        self.quotas = quotas
        self.resourceURI = resourceURI
        self.username = username
        self.storages = storages
        self.isLoggedIn = isLoggedIn
    }
    
    private enum CodingKeys: String, CodingKey {
        case allowedLanguages = "allowed_languages"
        case awskeys, email
        case firstName = "first_name"
        case groups
        case isVSS = "is_VSS"
        case language
        case lastName = "last_name"
        case login, nvwuid, preferences, quotas
        case resourceURI = "resource_uri"
        case username
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.allowedLanguages = try container.decode(String.self, forKey: CodingKeys.allowedLanguages)
        self.awskeys = try container.decode(VCSAWSkeys.self, forKey: CodingKeys.awskeys)
        self.email = try container.decode(String.self, forKey: CodingKeys.email)
        self.firstName = try container.decode(String.self, forKey: CodingKeys.firstName)
        self.groups = try container.decode([String].self, forKey: CodingKeys.groups)
        self.isVSS = try container.decode(Bool.self, forKey: CodingKeys.isVSS)
        self.language = try container.decode(String.self, forKey: CodingKeys.language)
        self.lastName = try container.decode(String.self, forKey: CodingKeys.lastName)
        self.login = try container.decode(String.self, forKey: CodingKeys.login)
        self.nvwuid = try container.decode(String.self, forKey: CodingKeys.nvwuid)
        self.preferences = try? container.decode(String.self, forKey: CodingKeys.preferences)
        self.quotas = try container.decode(Quotas.self, forKey: CodingKeys.quotas)
        self.resourceURI = try container.decode(String.self, forKey: CodingKeys.resourceURI)
        self.username = try container.decode(String.self, forKey: CodingKeys.username)
        self.isLoggedIn = false
        super.init()
    }
}

extension VCSUser: VCSCachable {
    public typealias RealmModel = RealmVCSUser
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSUser.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSUser.realmStorage.getByIdOfItem(item: self) != nil {
            VCSUser.realmStorage.partialUpdate(item: self)
        } else {
            VCSUser.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSUser.realmStorage.partialUpdate(item: self)
    }
}

extension VCSUser {
    public static var savedUser: VCSUser? {
        return VCSUser.realmStorage.getAll().first { $0.isLoggedIn }
    }
    
    public static func clearLoggedInUsers() {
        VCSUser.realmStorage.getAll().forEach { $0.updateIsLoggedIn(false) }
    }
}

public class VCSAWSkeys: NSObject, Codable {
    public let awsSynced: Bool
    public let linksExpireAfter: Int
    public let awskeysPrefix, s3Bucket, s3Key, s3Secret: String
    public let sampleFilesCopied: Int
    public let userData: String
    public let id: Int
    public let initializedOn, resourceURI: String
    
    init(awsSynced: Bool, linksExpireAfter: Int, awskeysPrefix: String, s3Bucket: String, s3Key: String, s3Secret: String, sampleFilesCopied: Int, userData: String, id: Int, initializedOn: String, resourceURI: String) {
        self.awsSynced = awsSynced
        self.linksExpireAfter = linksExpireAfter
        self.awskeysPrefix = awskeysPrefix
        self.s3Bucket = s3Bucket
        self.s3Key = s3Key
        self.s3Secret = s3Secret
        self.sampleFilesCopied = sampleFilesCopied
        self.userData = userData
        self.id = id
        self.initializedOn = initializedOn
        self.resourceURI = resourceURI
    }
    
    enum CodingKeys: String, CodingKey {
        case awsSynced = "AWSSynced"
        case linksExpireAfter = "LinksExpireAfter"
        case awskeysPrefix = "Prefix"
        case s3Bucket = "S3Bucket"
        case s3Key = "S3Key"
        case s3Secret = "S3Secret"
        case sampleFilesCopied = "SampleFilesCopied"
        case userData = "UserData"
        case id
        case initializedOn = "initialized_on"
        case resourceURI = "resource_uri"
    }
}

public class Quotas: NSObject, Codable {
    public let processingQuota: Int
    public let processingUsed: Double
    public let storageQuota, storageUsed: Int
    public let resourceURI: String
    
    init(processingQuota: Int, processingUsed: Double, storageQuota: Int, storageUsed: Int, resourceURI: String) {
        self.processingQuota = processingQuota
        self.processingUsed = processingUsed
        self.storageQuota = storageQuota
        self.storageUsed = storageUsed
        self.resourceURI = resourceURI
    }
    
    enum CodingKeys: String, CodingKey {
        case processingQuota = "ProcessingQuota"
        case processingUsed = "ProcessingUsed"
        case storageQuota = "StorageQuota"
        case storageUsed = "StorageUsed"
        case resourceURI = "resource_uri"
    }
}
