import Foundation
import SwiftData

//import RealmSwift
//
//class RealmJobFileVersionRequest: Object, VCSRealmObject {
//    typealias Model = JobFileVersionRequest
//    
//    @Persisted(primaryKey: true) var RealmID: String = ""
//    @Persisted var path: String = ""
//    @Persisted var provider: String = ""
//    @Persisted var owner: String = ""
//    @Persisted var isFolder: Bool = true
//    
//    required convenience init(model: JobFileVersionRequest) {
//        self.init()
//        self.path = model.path
//        self.provider = model.provider
//        self.owner = model.owner
//        self.isFolder = model.isFolder
//        self.RealmID = "\(self.path)/\(self.provider)"
//    }
//    
//    public var entity: JobFileVersionRequest {
//        return JobFileVersionRequest(path: self.path, provider: self.provider, owner: self.owner, isFolder: self.isFolder)
//    }
//    
//    public var partialUpdateModel: [String : Any] {
//        return [
//            "RealmID" : self.RealmID
//            , "path" : self.path
//            , "provider" : self.provider
//            , "owner" : self.owner
//            , "isFolder" : self.isFolder
//        ]
//    }
//}
//
//class RealmPhotogramOptionsRequest: Object, VCSRealmObject {
//    typealias Model = PhotogramOptionsRequest
//    @Persisted var RealmID: String = ""
//    @Persisted var srcStorageType: String = ""
//    @Persisted var outputStorageType: String = ""
//    @Persisted var outputLocation: String = ""
//    dynamic var srcFileVersions: List<RealmJobFileVersionRequest> = List()
//    
//    required convenience init(model: PhotogramOptionsRequest) {
//        self.init()
//        self.srcStorageType = model.srcStorageType
//        self.outputStorageType = model.outputStorageType
//        self.outputLocation = model.outputLocation
//        let realmJobFileVersions = List<RealmJobFileVersionRequest>()
//        model.srcFileVersions.forEach {
//            realmJobFileVersions.append(RealmJobFileVersionRequest(model: $0))
//        }
//        self.srcFileVersions = realmJobFileVersions
//        self.RealmID = self.outputStorageType
//    }
//    
//    public var entity: PhotogramOptionsRequest {
//        return PhotogramOptionsRequest(srcStorageType: self.srcStorageType, outputStorageType: self.outputStorageType, outputLocation: self.outputLocation, srcFileVersions: self.srcFileVersions.compactMap { $0.entity })
//    }
//    
//    public var partialUpdateModel: [String : Any] {
//        return [
//            "RealmID" : self.RealmID
//            , "srcStorageType" : self.srcStorageType
//            , "outputStorageType" : self.outputStorageType
//            , "outputLocation" : self.outputLocation
//            , "srcFileVersions" : self.srcFileVersions.compactMap { $0.partialUpdateModel }
//        ]
//    }
//}
//
//public class RealmPhotogramJobRequest: Object, VCSRealmObject {
//    public typealias Model = PhotogramJobRequest
//    
//    @Persisted(primaryKey: true) public var RealmID: String = ""
//    @Persisted var fileName: String = ""
//    @Persisted var jobType: String = ""
//    @Persisted var fileVersion: RealmJobFileVersionRequest!
//    @Persisted var options: RealmPhotogramOptionsRequest!
//    @Persisted var owner: String = ""
//    @Persisted var isQueued: Bool = false
//    
//    public required convenience init(model: PhotogramJobRequest) {
//        self.init()
//        self.fileName = model.fileName
//        self.jobType = model.jobType
//        self.fileVersion = RealmJobFileVersionRequest(model: model.fileVersion)
//        self.options = RealmPhotogramOptionsRequest(model: model.options)
//        let owner = VCSUser.savedUser?.login ?? ""
//        self.owner = owner
//        self.isQueued = model.isQueued
//        self.RealmID = "\(owner)/\(self.jobType)/\(self.fileName)"
//    }
//    
//    public var entity: PhotogramJobRequest {
//        return PhotogramJobRequest(fileName: self.fileName, jobType: self.jobType, fileVersion: self.fileVersion.entity, options: self.options.entity, isQueued: self.isQueued)
//    }
//    
//    public var partialUpdateModel: [String : Any] {
//        return [
//            "fileName" : self.fileName
//            , "jobType" : self.jobType
//            , "fileVersion" : self.fileVersion.partialUpdateModel
//            , "options" : self.options.partialUpdateModel
//            , "isQueued" : self.isQueued
//        ]
//    }
//}

@Model
public final class PhotogramJobRequest: Codable {
    public let fileName: String
    public let jobType: String
    public let fileVersion: JobFileVersionRequest
    public let options: PhotogramOptionsRequest
    public var isQueued: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case fileName
        case jobType = "job_type"
        case fileVersion = "file_version"
        case options
        case isQueued
    }
    
    public init(fileName:String, jobType:String, fileVersion: JobFileVersionRequest, options:PhotogramOptionsRequest, isQueued: Bool) {
        self.fileName = fileName
        self.jobType = jobType
        self.fileVersion = fileVersion
        self.options = options
        self.isQueued = isQueued
    }
    
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        fileName = try container.decode(String.self, forKey: .fileName)
        jobType = try container.decode(String.self, forKey: .jobType)
        fileVersion = try container.decode(JobFileVersionRequest.self, forKey: .fileVersion)
        options = try container.decode(PhotogramOptionsRequest.self, forKey: .options)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(fileName, forKey: .fileName)
        try container.encode(jobType, forKey: .jobType)
        try container.encode(fileVersion, forKey: .fileVersion)
        try container.encode(options, forKey: .options)
        try container.encode(isQueued, forKey: .isQueued)
    }
}

extension PhotogramJobRequest: VCSCacheable {
    public var rID: String { return fileName + jobType }
    
}

public class JobFileVersionRequest: NSObject, Codable {
    public let path:String
    public let provider:String
    public let owner:String
    public let isFolder:Bool
    
    enum CodingKeys: String, CodingKey {
        case path
        case provider
        case owner
        case isFolder = "is_folder"
    }
    
    public init(path:String, provider:String, owner:String, isFolder:Bool = false) {
        self.path = path
        self.provider = provider
        self.owner = owner
        self.isFolder = isFolder
    }
}

public class PhotogramOptionsRequest: NSObject, Codable {
    public let srcStorageType:String
    public let srcFileVersions:[JobFileVersionRequest]
    public let outputStorageType:String
    public let outputLocation:String
    
    enum CodingKeys: String, CodingKey {
        case srcStorageType = "src_storage_type"
        case srcFileVersions = "src_file_versions"
        case outputStorageType = "output_storage_type"
        case outputLocation = "output_location"
    }
    
    public init(srcStorageType:String, outputStorageType:String, outputLocation:String, srcFileVersions:[JobFileVersionRequest]) {
        self.srcStorageType = srcStorageType
        self.outputStorageType = outputStorageType
        self.outputLocation = outputLocation
        self.srcFileVersions = srcFileVersions
    }
}
