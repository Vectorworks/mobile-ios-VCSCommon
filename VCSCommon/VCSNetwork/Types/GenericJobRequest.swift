import Foundation

public class GenericJobRequest: NSObject, Codable {
    public let jobType:String
    public let fileVersion: JobFileVersionRequest
    public let options: GenericJobOptionsRequest
    
    enum CodingKeys: String, CodingKey {
        case jobType = "job_type"
        case fileVersion = "file_version"
        case options
    }
    
    public init(jobType:String, fileVersion: JobFileVersionRequest, options: GenericJobOptionsRequest) {
        self.jobType = jobType
        self.fileVersion = fileVersion
        self.options = options
    }
}

public enum GenericJobOptionOperations: String {
    case usdz2obj
    case measure
}

public class GenericJobOptionsRequest: NSObject, Codable {
    public let jobName:String
    public let operation: String
    public let outputStorageType: String
    public let outputLocation: String
    public let outputOwner: String
    
    enum CodingKeys: String, CodingKey {
        case jobName = "job_name"
        case operation
        case outputStorageType = "output_storage_type"
        case outputLocation = "output_location"
        case outputOwner = "output_location_owner"
    }
    
    public init(jobName:String, operation:String, outputStorageType:String, outputLocation:String, outputOwner: String) {
        self.jobName = jobName
        self.operation = operation
        self.outputStorageType = outputStorageType
        self.outputLocation = outputLocation
        self.outputOwner = outputOwner
    }
}
