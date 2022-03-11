import Foundation
import RealmSwift

public class RealmJobData: Object, VCSRealmObject {
    public typealias Model = VCSJobResponse
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var id: Int = 0
    @objc dynamic var user: String = ""
    @objc dynamic var fileVersion: RealmJobFileVersion?
    @objc dynamic var vw: Int = 0
    @objc dynamic var jobType: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var statusData: String = ""
    @objc dynamic var lastUpdate: String = ""
    @objc dynamic var userData: String = ""
    @objc dynamic var timeRemaining: Int = 0
    @objc dynamic var submissionTimestamp: String = ""
    @objc dynamic var startTimestamp: String = ""
    @objc dynamic var endTimestamp: String = ""
    @objc dynamic var outputfile: String = ""
    @objc dynamic var usedPUs: Double = 0
    @objc dynamic var usedFUs: Double = 0
    @objc dynamic var options: RealmJobOptions?
    @objc dynamic var origin: String = ""
    
    @objc dynamic var lastEvent: RealmJobEventData?
    
    
    public required convenience init(model: Model) {
        self.init()
        
        self.RealmID = String(model.id)
        self.id = model.id
        self.user = model.user
        if let fileVersion = model.fileVersion {
            self.fileVersion = RealmJobFileVersion(model: fileVersion)
        }
        self.vw = model.vw ?? 0
        self.jobType = model.jobType
        self.status = model.status
        self.statusData = model.statusData
        self.lastUpdate = model.lastUpdate
        self.userData = model.userData
        self.timeRemaining = model.timeRemaining
        self.submissionTimestamp = model.submissionTimestamp
        self.startTimestamp = model.startTimestamp
        self.endTimestamp = model.endTimestamp
        self.outputfile = model.outputfile
        self.usedPUs = model.usedPUs
        self.usedFUs = model.usedFUs
        if let options = model.options {
            self.options = RealmJobOptions(model: options)
        }
        if let lastEvent = model.lastEvent {
            self.lastEvent = RealmJobEventData(model: lastEvent)
        }
        self.origin = model.origin
    }
    
    public var entity: Model {
        return VCSJobResponse(id: self.id, user: self.user, fileVersion: self.fileVersion?.entity, vw: self.vw, jobType: self.jobType, status: self.status, statusData: self.statusData, lastUpdate: self.lastUpdate, userData: self.userData, timeRemaining: self.timeRemaining, submissionTimestamp: self.submissionTimestamp, startTimestamp: self.startTimestamp, endTimestamp: self.endTimestamp, outputfile: self.outputfile, usedPUs: self.usedPUs, usedFUs: self.usedFUs, options: self.options?.entity, origin: self.origin, lastEvent: self.lastEvent?.entity)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["id"] = self.id
        result["user"] = self.user
        if let fileVersion = self.fileVersion?.partialUpdateModel {
            result["fileVersion"] = fileVersion
        }
        result["vw"] = self.vw
        result["jobType"] = self.jobType
        result["status"] = self.status
        result["statusData"] = self.statusData
        result["lastUpdate"] = self.lastUpdate
        result["userData"] = self.userData
        result["timeRemaining"] = self.timeRemaining
        result["submissionTimestamp"] = self.submissionTimestamp
        result["startTimestamp"] = self.startTimestamp
        result["endTimestamp"] = self.endTimestamp
        result["outputfile"] = self.outputfile
        result["usedPUs"] = self.usedPUs
        result["usedFUs"] = self.usedFUs
        if let options = self.options?.partialUpdateModel {
            result["options"] = options
        }
        if let lastEvent = self.lastEvent?.partialUpdateModel {
            result["lastEvent"] = lastEvent
        }
        result["origin"] = self.origin
        
        return result
    }
}
