import Foundation

@objc public class VCSJobOptionsResponse: NSObject, Codable {
    public let options, jobName, operation: String?
    public let srcFileVersions: [VCSJobFileVersionResponse]
    public let outputLocation: String?
    public let outputStorageType: String
    public let currentFile, logFile: String?
    public let refFileVersions: [VCSJobFileVersionResponse]
    public let srcStorageType: String
    
    enum CodingKeys: String, CodingKey {
        case options
        case jobName = "job_name"
        case operation
        case srcFileVersions = "src_file_versions"
        case outputLocation = "output_location"
        case outputStorageType = "output_storage_type"
        case currentFile = "current_file"
        case logFile = "log_file"
        case refFileVersions = "ref_file_versions"
        case srcStorageType = "src_storage_type"
    }
    
    init(srcStorageType: String, outputStorageType: String, srcFileVersions: [VCSJobFileVersionResponse], refFileVersions: [VCSJobFileVersionResponse], options: String?, jobName: String?, operation: String?, outputLocation: String?, currentFile: String?, logFile: String?) {
        self.srcStorageType = srcStorageType
        self.outputStorageType = outputStorageType
        self.srcFileVersions = srcFileVersions
        self.refFileVersions = refFileVersions
        self.options = options
        self.jobName = jobName
        self.operation = operation
        self.outputLocation = outputLocation
        self.currentFile = currentFile
        self.logFile = logFile
    }
}

extension VCSJobOptionsResponse: VCSCachable {
    public typealias RealmModel = RealmJobOptions
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSJobOptionsResponse.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSJobOptionsResponse.realmStorage.getByIdOfItem(item: self) != nil {
            VCSJobOptionsResponse.realmStorage.partialUpdate(item: self)
        } else {
            VCSJobOptionsResponse.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSJobOptionsResponse.realmStorage.partialUpdate(item: self)
    }
}
