import Foundation
import RealmSwift

public class RealmJobOptions: Object, VCSRealmObject {
    public typealias Model = VCSJobOptionsResponse
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var srcStorageType: String = ""
    @objc dynamic var outputStorageType: String = ""
    @objc dynamic var options, jobName, operation: String?
    dynamic var srcFileInfo: RealmJobFileInfo? = nil
    dynamic var srcFileVersions: List<RealmJobFileVersion> = List()
    @objc dynamic var outputLocation: String?
    @objc dynamic var currentFile, logFile: String?
    
    
    public required convenience init(model: Model) {
        self.init()
        
        self.RealmID = UUID().uuidString
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
