import Foundation
import SwiftData

@Model
public final class VCSJobOptionsResponse: Codable {
    public let options: String? = nil
    public let jobName: String?
    public let operation: String?
    public let srcFileInfo: VCSJobFileInfoResponse?
    public let srcFileVersions: [VCSJobFileVersionResponse]
    public let outputLocation: String?
    public let outputStorageType: String
    public let currentFile: String?
    public let logFile: String?
    public let srcStorageType: String
    
    enum CodingKeys: String, CodingKey {
        case options
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
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.options = try container.decode(String?.self, forKey: CodingKeys.options)
        self.jobName = try container.decode(String?.self, forKey: CodingKeys.jobName)
        self.operation = try container.decode(String?.self, forKey: CodingKeys.operation)
        self.srcFileInfo = try container.decode(VCSJobFileInfoResponse?.self, forKey: CodingKeys.srcFileInfo)
        self.srcFileVersions = try container.decode([VCSJobFileVersionResponse].self, forKey: CodingKeys.srcFileVersions)
        self.outputLocation = try container.decode(String?.self, forKey: CodingKeys.outputLocation)
        self.outputStorageType = try container.decode(String.self, forKey: CodingKeys.outputStorageType)
        self.currentFile = try container.decode(String?.self, forKey: CodingKeys.currentFile)
        self.logFile = try container.decode(String?.self, forKey: CodingKeys.logFile)
        self.srcStorageType = try container.decode(String.self, forKey: CodingKeys.srcStorageType)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.options, forKey: CodingKeys.options)
        try container.encode(self.jobName, forKey: CodingKeys.jobName)
        try container.encode(self.operation, forKey: CodingKeys.operation)
        try container.encode(self.srcFileInfo, forKey: CodingKeys.srcFileInfo)
        try container.encode(self.srcFileVersions, forKey: CodingKeys.srcFileVersions)
        try container.encode(self.outputStorageType, forKey: CodingKeys.outputStorageType)
        try container.encode(self.currentFile, forKey: CodingKeys.currentFile)
        try container.encode(self.logFile, forKey: CodingKeys.logFile)
        try container.encode(self.srcStorageType, forKey: CodingKeys.srcStorageType)
    }
}

extension VCSJobOptionsResponse: VCSCacheable {
    public var rID: String { return VCSUUID().systemUUID.uuidString }
}
