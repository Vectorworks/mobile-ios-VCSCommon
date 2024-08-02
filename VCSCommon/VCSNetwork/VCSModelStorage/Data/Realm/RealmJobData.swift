//import Foundation
//import RealmSwift
//
//public class RealmJobData: Object, VCSRealmObject {
//    public typealias Model = VCSJobResponse
//    
//    @Persisted(primaryKey: true) public var RealmID: String = "nil"
//    @Persisted public var id: Int = 0
//    @Persisted var user: String = ""
//    @Persisted var fileVersion: RealmJobFileVersion?
//    @Persisted var vw: Int = 0
//    @Persisted var jobType: String = ""
//    @Persisted var status: String = ""
//    @Persisted var statusData: String = ""
//    @Persisted var lastUpdate: String = ""
//    @Persisted var userData: String = ""
//    @Persisted var timeRemaining: Int = 0
//    @Persisted var submissionTimestamp: String = ""
//    @Persisted var startTimestamp: String = ""
//    @Persisted var endTimestamp: String = ""
//    @Persisted var outputfile: String = ""
//    @Persisted var usedPUs: Double = 0
//    @Persisted var usedFUs: Double = 0
//    @Persisted var options: RealmJobOptions?
//    @Persisted var origin: String = ""
//    
//    @Persisted var lastEvent: RealmJobEventData?
//    
//    
//    public required convenience init(model: Model) {
//        self.init()
//        
//        self.RealmID = String(model.id)
//        self.id = model.id
//        self.user = model.user
//        if let fileVersion = model.fileVersion {
//            self.fileVersion = RealmJobFileVersion(model: fileVersion)
//        }
//        self.vw = model.vw ?? 0
//        self.jobType = model.jobType
//        self.status = model.status
//        self.statusData = model.statusData
//        self.lastUpdate = model.lastUpdate
//        self.userData = model.userData
//        self.timeRemaining = model.timeRemaining
//        self.submissionTimestamp = model.submissionTimestamp
//        self.startTimestamp = model.startTimestamp
//        self.endTimestamp = model.endTimestamp
//        self.outputfile = model.outputfile
//        self.usedPUs = model.usedPUs
//        self.usedFUs = model.usedFUs
//        if let options = model.options {
//            self.options = RealmJobOptions(model: options)
//        }
//        if let lastEvent = model.lastEvent {
//            self.lastEvent = RealmJobEventData(model: lastEvent)
//        }
//        self.origin = model.origin
//    }
//    
//    public var entity: Model {
//        return VCSJobResponse(id: self.id, user: self.user, fileVersion: self.fileVersion?.entity, vw: self.vw, jobType: self.jobType, status: self.status, statusData: self.statusData, lastUpdate: self.lastUpdate, userData: self.userData, timeRemaining: self.timeRemaining, submissionTimestamp: self.submissionTimestamp, startTimestamp: self.startTimestamp, endTimestamp: self.endTimestamp, outputfile: self.outputfile, usedPUs: self.usedPUs, usedFUs: self.usedFUs, options: self.options?.entity, origin: self.origin, lastEvent: self.lastEvent?.entity)
//    }
//    
//    public var partialUpdateModel: [String : Any] {
//        var result: [String : Any] = [:]
//        
//        result["RealmID"] = self.RealmID
//        result["id"] = self.id
//        result["user"] = self.user
//        if let fileVersion = self.fileVersion?.partialUpdateModel {
//            result["fileVersion"] = fileVersion
//        }
//        result["vw"] = self.vw
//        result["jobType"] = self.jobType
//        result["status"] = self.status
//        result["statusData"] = self.statusData
//        result["lastUpdate"] = self.lastUpdate
//        result["userData"] = self.userData
//        result["timeRemaining"] = self.timeRemaining
//        result["submissionTimestamp"] = self.submissionTimestamp
//        result["startTimestamp"] = self.startTimestamp
//        result["endTimestamp"] = self.endTimestamp
//        result["outputfile"] = self.outputfile
//        result["usedPUs"] = self.usedPUs
//        result["usedFUs"] = self.usedFUs
//        if let options = self.options?.partialUpdateModel {
//            result["options"] = options
//        }
//        if let lastEvent = self.lastEvent?.partialUpdateModel {
//            result["lastEvent"] = lastEvent
//        }
//        result["origin"] = self.origin
//        
//        return result
//    }
//}
