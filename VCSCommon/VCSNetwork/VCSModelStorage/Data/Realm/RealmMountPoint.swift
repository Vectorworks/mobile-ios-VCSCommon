import Foundation
import RealmSwift

public class RealmMountPoint: Object, VCSRealmObject {
    public typealias Model = VCSMountPointResponse
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var storageType: String = StorageType.S3.rawValue
    @objc dynamic var prefix: String = ""
    @objc dynamic var path: String = ""
    @objc dynamic var mountPath: String = ""
    
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
