import Foundation
import SwiftData
import CocoaLumberjackSwift

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

@Model
public final class VCSUser: Codable {
    public let allowedLanguages: String
    public let email: String
    public let firstName: String
    public let groups: [String]
    public let isVSS: Bool
    public let language: String
    public let lastName: String
    public let login: String
    public let nvwuid: String
    public let preferences: String?
    @Relationship(deleteRule: .cascade)
    public let quotas: Quotas
    public let resourceURI: String
    public let username: String
    public var availableStorages: StorageList { return self.storages }
    internal var storages: StorageList = []
    private(set) public var isLoggedIn: Bool = false
    
    public func addAvailableStorage(storage: VCSStorageResponse) {
        guard !self.storages.contains(storage) else { return }
        self.storages.append(storage)
        self.addToCache()
    }
    
    public func setStorageList(storages: StorageList) {
        self.storages.removeAll()
        storages.forEach { (storage: VCSStorageResponse) in
            storage.loadLocalPagesList()
        }
        self.storages.append(contentsOf: storages)
        self.addToCache()
    }
    
    public func removeAvailableStorage(storage: VCSStorageResponse) {
        guard self.storages.contains(storage),
            let index = self.storages.firstIndex(of: storage) else { return }
        
        self.storages.remove(at: index)
        self.addToCache()
    }
    
    public func removeAvailableStorage(storageType: StorageType) {
        guard let index = self.storages.firstIndex(where: { $0.storageType == storageType }) else { return }
        
        self.storages.remove(at: index)
        self.addToCache()
    }
    
    public func updateIsLoggedIn(_ value: Bool) {
        defer { self.addToCache() }
        
        self.isLoggedIn = value
    }
    
    
    init(allowedLanguages: String, email: String, firstName: String, groups: [String], isVSS: Bool, language: String, lastName: String, login: String, nvwuid: String, preferences: String?, quotas: Quotas, resourceURI: String, username: String, storages: StorageList, isLoggedIn: Bool) {
        self.allowedLanguages = allowedLanguages
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
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.allowedLanguages, forKey: CodingKeys.allowedLanguages)
        try container.encode(self.email, forKey: CodingKeys.email)
        try container.encode(self.firstName, forKey: CodingKeys.firstName)
        try container.encode(self.groups, forKey: CodingKeys.groups)
        try container.encode(self.isVSS, forKey: CodingKeys.isVSS)
        try container.encode(self.language, forKey: CodingKeys.language)
        try container.encode(self.lastName, forKey: CodingKeys.lastName)
        try container.encode(self.login, forKey: CodingKeys.login)
        try container.encode(self.nvwuid, forKey: CodingKeys.nvwuid)
        try container.encode(self.preferences, forKey: CodingKeys.preferences)
        try container.encode(self.quotas, forKey: CodingKeys.quotas)
        try container.encode(self.resourceURI, forKey: CodingKeys.resourceURI)
        try container.encode(self.username, forKey: CodingKeys.username)
    }
}

extension VCSUser: VCSCacheable {
    public var rID: String { return login }
}

extension VCSUser {
    public static var savedUser: VCSUser? {
        do {
            let fetchDescriptor = FetchDescriptor<VCSUser>(predicate: #Predicate { user in
                user.isLoggedIn
            })
            let modelContext = ModelContext(VCSCache.persistentContainer)
            let data = try modelContext.fetch(fetchDescriptor)
            return data.first
        } catch {
            return nil
        }
        
        //TODO: REALM_CHANGE
        return nil//VCSUser.realmStorage.getAll().first { $0.isLoggedIn }
    }
    
    public static func clearLoggedInUsers() {
//        VCSUser.realmStorage.getAll().forEach { $0.updateIsLoggedIn(false) }
    }
}

//public class VCSAWSkeys: NSObject, Codable {
//    public let awsSynced: Bool
//    public let linksExpireAfter: Int
//    public let awskeysPrefix, s3Bucket, s3Key, s3Secret: String
//    public let sampleFilesCopied: Int
//    public let userData: String
//    public let id: Int
//    public let initializedOn, resourceURI: String
//    
//    init(awsSynced: Bool, linksExpireAfter: Int, awskeysPrefix: String, s3Bucket: String, s3Key: String, s3Secret: String, sampleFilesCopied: Int, userData: String, id: Int, initializedOn: String, resourceURI: String) {
//        self.awsSynced = awsSynced
//        self.linksExpireAfter = linksExpireAfter
//        self.awskeysPrefix = awskeysPrefix
//        self.s3Bucket = s3Bucket
//        self.s3Key = s3Key
//        self.s3Secret = s3Secret
//        self.sampleFilesCopied = sampleFilesCopied
//        self.userData = userData
//        self.id = id
//        self.initializedOn = initializedOn
//        self.resourceURI = resourceURI
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case awsSynced = "AWSSynced"
//        case linksExpireAfter = "LinksExpireAfter"
//        case awskeysPrefix = "Prefix"
//        case s3Bucket = "S3Bucket"
//        case s3Key = "S3Key"
//        case s3Secret = "S3Secret"
//        case sampleFilesCopied = "SampleFilesCopied"
//        case userData = "UserData"
//        case id
//        case initializedOn = "initialized_on"
//        case resourceURI = "resource_uri"
//    }
//}

@Model
public class Quotas: Codable {
    public let processingQuota: Int
    public let processingUsed: Double
    public let storageQuota: Int
    public let storageUsed: Int
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
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.processingQuota = try container.decode(Int.self, forKey: CodingKeys.processingQuota)
        self.processingUsed = try container.decode(Double.self, forKey: CodingKeys.processingUsed)
        self.storageQuota = try container.decode(Int.self, forKey: CodingKeys.storageQuota)
        self.storageUsed = try container.decode(Int.self, forKey: CodingKeys.storageUsed)
        self.resourceURI = try container.decode(String.self, forKey: CodingKeys.resourceURI)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.processingQuota, forKey: CodingKeys.processingQuota)
        try container.encode(self.processingUsed, forKey: CodingKeys.processingUsed)
        try container.encode(self.storageQuota, forKey: CodingKeys.storageQuota)
        try container.encode(self.storageUsed, forKey: CodingKeys.storageUsed)
        try container.encode(self.resourceURI, forKey: CodingKeys.resourceURI)
    }
}
