import Foundation
import RealmSwift

public class RealmJobEventData: Object, VCSRealmObject {
    public typealias Model = VCSJobEventResponse
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic public var id: Int = 0
    @objc dynamic var jobType: String = ""
    @objc dynamic var lastUpdate: String = ""
    @objc dynamic var sequenceNumber: Int = 0
    @objc dynamic var status: String = ""
    @objc dynamic var statusData: String = ""
    @objc dynamic var storageType: String = ""
    @objc dynamic var timeRemaining: Int = 0
    @objc dynamic var timestamp: String = ""
    @objc dynamic var usedPUs: Double = 0
    
    
    public required convenience init(model: Model) {
        self.init()
        
        self.RealmID = String(model.id)
        self.id = model.id
        self.jobType = model.jobType
        self.lastUpdate = model.lastUpdate
        self.sequenceNumber = model.sequenceNumber
        self.status = model.status
        self.statusData = model.statusData
        self.storageType = model.storageType
        self.timeRemaining = model.timeRemaining
        self.timestamp = model.timestamp
        self.usedPUs = model.usedPUs
    }
    
    public var entity: Model {
        return VCSJobEventResponse(id: self.id, jobType: self.jobType, lastUpdate: self.lastUpdate, sequenceNumber: self.sequenceNumber, status: self.status, statusData: self.statusData, storageType: self.storageType, timeRemaining: self.timeRemaining, timestamp: self.timestamp, usedPUs: self.usedPUs)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["id"] = self.id
        result["jobType"] = self.jobType
        result["lastUpdate"] = self.lastUpdate
        result["sequenceNumber"] = self.sequenceNumber
        result["status"] = self.status
        result["statusData"] = self.statusData
        result["storageType"] = self.storageType
        result["timeRemaining"] = self.timeRemaining
        result["timestamp"] = self.timestamp
        result["usedPUs"] = self.usedPUs
        
        return result
    }
}
