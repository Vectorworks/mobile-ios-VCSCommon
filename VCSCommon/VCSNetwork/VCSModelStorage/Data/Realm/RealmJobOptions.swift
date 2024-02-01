import Foundation
import RealmSwift

public class RealmJobOptions: Object, VCSRealmObject {
    public typealias Model = VCSJobOptionsResponse
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted var srcStorageType: String = ""
    @Persisted var outputStorageType: String = ""
    @Persisted var options: String?
    @Persisted var jobName: String?
    @Persisted var operation: String?
    @Persisted var srcFileInfo: RealmJobFileInfo? = nil
    @Persisted var srcFileVersions: List<RealmJobFileVersion> = List()
    @Persisted var outputLocation: String?
    @Persisted var currentFile: String?
    @Persisted var logFile: String?
    
    
    public required convenience init(model: Model) {
        self.init()
        
        self.RealmID = VCSUUID().systemUUID.uuidString
        self.srcStorageType = model.srcStorageType
        self.options = model.options
        self.jobName = model.jobName
        self.operation = model.operation
        self.outputLocation = model.outputLocation
        self.outputStorageType = model.outputStorageType
        self.currentFile = model.currentFile
        self.logFile = model.logFile
        
        let srcFileVersionsArray = model.srcFileVersions
        let realmSrcFileVersionsArray = List<RealmJobFileVersion>()
        srcFileVersionsArray.forEach {
            realmSrcFileVersionsArray.append(RealmJobFileVersion(model: $0))
        }
        self.srcFileVersions = realmSrcFileVersionsArray
    }
    
    public var entity: Model {
        let srcFileVersionsArray = self.srcFileVersions.compactMap({ $0.entity })
        let srcFileVersions = Array(srcFileVersionsArray)
        
        return VCSJobOptionsResponse(srcStorageType: self.srcStorageType, outputStorageType: self.outputStorageType, srcFileInfo: self.srcFileInfo?.entity, srcFileVersions: srcFileVersions, options: self.options, jobName: self.jobName, operation: self.operation, outputLocation: self.outputLocation, currentFile: self.currentFile, logFile: self.logFile)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["srcStorageType"] = self.srcStorageType
        result["options"] = self.options
        result["jobName"] = self.jobName
        result["operation"] = self.operation
        result["outputLocation"] = self.outputLocation
        result["outputStorageType"] = self.outputStorageType
        result["currentFile"] = self.currentFile
        result["logFile"] = self.logFile
        
        return result
    }
}
