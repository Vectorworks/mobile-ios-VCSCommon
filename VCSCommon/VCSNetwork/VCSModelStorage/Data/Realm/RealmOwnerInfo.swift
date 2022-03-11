import Foundation
import RealmSwift

public class RealmOwnerInfo: Object, VCSRealmObject {
    public typealias Model = VCSOwnerInfoResponse
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var owner: String = ""
    @objc dynamic var ownerEmail: String = ""
    @objc dynamic var ownerName: String = ""
    @objc dynamic var uploadPrefix: String = ""
    @objc dynamic public var hasJoined: Bool = false
    dynamic var permission: List<String> = List()
    @objc dynamic var dateCreated: String = ""
    @objc dynamic var sharedParentFolder: String = ""
    @objc dynamic var mountPoint: RealmMountPoint?
    
    
    public required convenience init(model: Model) {
        self.init()
        
        self.RealmID = model.realmID
        self.owner = model.owner
        self.ownerEmail = model.ownerEmail
        self.ownerName = model.ownerName
        self.uploadPrefix = model.uploadPrefix
        self.dateCreated = model.dateCreated
        self.sharedParentFolder = model.sharedParentFolder
        if let mountPoint = model.mountPoint {
            mountPoint.realmID = self.RealmID
            self.mountPoint = RealmMountPoint(model: mountPoint)
        }
        
        let realmPermissionArray = List<String>()
        model.permission.map { $0.rawValue }.forEach {
            realmPermissionArray.append($0)
        }
        
        self.permission = realmPermissionArray
    }
    
    public var entity: Model {
        let permissionArray = self.permission.compactMap({ $0 })
        let arrPermission = Array(permissionArray)
        
        return VCSOwnerInfoResponse(owner: self.owner, ownerEmail: self.ownerEmail, ownerName: self.ownerName, uploadPrefix: self.uploadPrefix, hasJoined: self.hasJoined, permission: arrPermission, dateCreated: self.dateCreated, sharedParentFolder: self.sharedParentFolder, mountPoint: self.mountPoint?.entity, realmID: self.RealmID)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["owner"] = self.owner
        result["ownerEmail"] = self.ownerEmail
        result["ownerName"] = self.ownerName
        result["uploadPrefix"] = self.uploadPrefix
        result["dateCreated"] = self.dateCreated
        result["sharedParentFolder"] = self.sharedParentFolder
        result["mountPoint"] = self.mountPoint?.partialUpdateModel
        result["permission"] = Array(self.permission.compactMap({ $0 }))
        
        return result
    }
}
