import Foundation
import RealmSwift

public class RealmQuotas: Object, VCSRealmObject {
    public typealias Model = Quotas
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted var processingQuota: Int = 0
    @Persisted var processingUsed: Double = 0
    @Persisted var storageQuota: Int = 0
    @Persisted var storageUsed: Int = 0
    
    public required convenience init(model: Model) {
        self.init()
        self.RealmID = model.resourceURI
        self.processingQuota = model.processingQuota
        self.processingUsed = model.processingUsed
        self.storageQuota = model.storageQuota
        self.storageUsed = model.storageUsed
    }
    
    public var entity: Model {
        return Quotas(processingQuota: self.processingQuota, processingUsed: self.processingUsed, storageQuota: self.storageQuota, storageUsed: self.storageUsed, resourceURI: self.RealmID)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["processingQuota"] = self.processingQuota
        result["processingUsed"] = self.processingUsed
        result["storageQuota"] = self.storageQuota
        result["storageUsed"] = self.storageUsed
        
        return result
    }
}
