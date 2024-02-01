import Foundation
import RealmSwift

public class RealmMountPoint: Object, VCSRealmObject {
    public typealias Model = VCSMountPointResponse
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted var storageType: String = StorageType.S3.rawValue
    @Persisted var prefix: String = ""
    @Persisted var path: String = ""
    @Persisted var mountPath: String = ""
    
    public required convenience init(model: Model) {
        self.init()
        
        self.RealmID = model.realmID
        self.storageType = model.storageType.rawValue
        self.prefix = model.prefix
        self.path = model.path
        self.mountPath = model.mountPath
    }
    
    public var entity: Model {
        return VCSMountPointResponse(storageType: StorageType.typeFromString(type: self.storageType), prefix: self.prefix, path: self.path, mountPath: self.mountPath, realmID: self.RealmID)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["storageType"] = self.storageType
        result["prefix"] = self.prefix
        result["path"] = self.path
        result["mountPath"] = self.mountPath
        
        return result
    }
}
