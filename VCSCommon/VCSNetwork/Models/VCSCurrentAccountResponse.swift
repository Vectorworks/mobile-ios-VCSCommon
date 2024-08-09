import Foundation

public class VCSCurrentAccountResponse: Codable {
    public let login: String
    public  let email: String
    public let firstName: String
    public let lastName: String
    public let quotas: VCSQuota
    
    enum CodingKeys: String, CodingKey {
        case login, email
        case firstName = "first_name"
        case lastName = "last_name"
        case quotas = "quotas"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.login = try container.decode(String.self, forKey: CodingKeys.login)
        self.email = try container.decode(String.self, forKey: CodingKeys.email)
        self.firstName = try container.decode(String.self, forKey: CodingKeys.firstName)
        self.lastName = try container.decode(String.self, forKey: CodingKeys.lastName)
        self.quotas = try container.decode(VCSQuota.self, forKey: CodingKeys.quotas)
    }
}

public class VCSQuota: Codable {
    public let storageUsed: Double
    public let processingUsed: Double
    public let storageQuota: Double
    public let processingQuota: Double
    public let storageUsedRaw: Int
    public let totalStorageUsed: Int
    
    enum CodingKeys: String, CodingKey {
        case storageUsed = "StorageUsed"
        case processingUsed = "ProcessingUsed"
        case storageQuota = "StorageQuota"
        case processingQuota = "ProcessingQuota"
        case storageUsedRaw = "storage_used"
        case totalStorageUsed = "total_storage_used"
    }
}
