import Foundation
import RealmSwift

public class RealmUploadJob: Object, VCSRealmObject {
    public typealias Model = UploadJob
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    
    @objc dynamic var jobOperation: String = ""
    @objc dynamic var owner: String = ""
    public dynamic var localFiles: List<RealmUploadJobLocalFile> = List()
    public dynamic var parentFolder: RealmFolder?
    
    public required convenience init(model: Model) {
        self.init()
        self.RealmID = model.jobID
        
        self.jobOperation = model.jobOperation.rawValue
        self.owner = model.owner
        
        let localFilesArray = model.localFiles
        let realmLocalFilesArray = List<RealmUploadJobLocalFile>()
        localFilesArray.forEach {
            realmLocalFilesArray.append(RealmUploadJobLocalFile(model: $0))
        }
        self.localFiles = realmLocalFilesArray
    }
    
    
    public var entity: UploadJob {
        let localFilesArray = self.localFiles.compactMap({ $0.entity })
        let arrLocalFiles = Array(localFilesArray)
        
        return UploadJob(jobID: self.RealmID,
                         jobOperation: UploadJob.JobType(rawValue: jobOperation) ?? UploadJob.JobType.MultipleFileUpload,
                         localFiles: arrLocalFiles,
                         owner: self.owner,
                         parentFolder: self.parentFolder?.entity)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        
        result["jobOperation"] = self.jobOperation
        
        let partialLocalFiles = Array(self.localFiles.compactMap({ $0.partialUpdateModel }))
        result["localFiles"] = partialLocalFiles
        
        return result
    }
}
