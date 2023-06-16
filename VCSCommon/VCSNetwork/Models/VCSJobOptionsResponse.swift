import Foundation

@objc public class VCSJobOptionsResponse: NSObject, Codable {
    public let options: String? = nil
    public let jobName, operation: String?
    public let srcFileInfo: VCSJobFileInfoResponse?
    public let srcFileVersions: [VCSJobFileVersionResponse]
    public let outputLocation: String?
    public let outputStorageType: String
    public let currentFile, logFile: String?
    public let srcStorageType: String
    
    enum CodingKeys: String, CodingKey {
//        case options
        case jobName = "job_name"
        case operation
        case srcFileInfo = "src_file_info"
        case srcFileVersions = "src_file_versions"
        case outputLocation = "output_location"
        case outputStorageType = "output_storage_type"
        case currentFile = "current_file"
        case logFile = "log_file"
        case srcStorageType = "src_storage_type"
    }
    
    init(srcStorageType: String, outputStorageType: String, srcFileInfo: VCSJobFileInfoResponse?, srcFileVersions: [VCSJobFileVersionResponse], options: String?, jobName: String?, operation: String?, outputLocation: String?, currentFile: String?, logFile: String?) {
        self.srcStorageType = srcStorageType
        self.outputStorageType = outputStorageType
        self.srcFileInfo = srcFileInfo
        self.srcFileVersions = srcFileVersions
//        self.options = options
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
