//import Foundation
//import RealmSwift
//
//public class RealmJobEventData: Object, VCSRealmObject {
//    public typealias Model = VCSJobEventResponse
//    
//    @Persisted(primaryKey: true) public var RealmID: String = "nil"
//    @Persisted public var id: Int = 0
//    @Persisted var jobType: String = ""
//    @Persisted var lastUpdate: String = ""
//    @Persisted var sequenceNumber: Int = 0
//    @Persisted var status: String = ""
//    @Persisted var statusData: String = ""
//    @Persisted var storageType: String = ""
//    @Persisted var timeRemaining: Int = 0
//    @Persisted var timestamp: String = ""
//    @Persisted var usedPUs: Double = 0
//    
//    
//    public required convenience init(model: Model) {
//        self.init()
//        
//        self.RealmID = String(model.id)
//        self.id = model.id
//        self.jobType = model.jobType
//        self.lastUpdate = model.lastUpdate
//        self.sequenceNumber = model.sequenceNumber
//        self.status = model.status
//        self.statusData = model.statusData
//        self.storageType = model.storageType
//        self.timeRemaining = model.timeRemaining
//        self.timestamp = model.timestamp
//        self.usedPUs = model.usedPUs
//    }
//    
//    public var entity: Model {
//        return VCSJobEventResponse(id: self.id, jobType: self.jobType, lastUpdate: self.lastUpdate, sequenceNumber: self.sequenceNumber, status: self.status, statusData: self.statusData, storageType: self.storageType, timeRemaining: self.timeRemaining, timestamp: self.timestamp, usedPUs: self.usedPUs)
//    }
//    
//    public var partialUpdateModel: [String : Any] {
//        var result: [String : Any] = [:]
//        
//        result["RealmID"] = self.RealmID
//        result["id"] = self.id
//        result["jobType"] = self.jobType
//        result["lastUpdate"] = self.lastUpdate
//        result["sequenceNumber"] = self.sequenceNumber
//        result["status"] = self.status
//        result["statusData"] = self.statusData
//        result["storageType"] = self.storageType
//        result["timeRemaining"] = self.timeRemaining
//        result["timestamp"] = self.timestamp
//        result["usedPUs"] = self.usedPUs
//        
//        return result
//    }
//}
