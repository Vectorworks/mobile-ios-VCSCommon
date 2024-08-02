//import Foundation
//import RealmSwift
//
//public class RealmOwnerInfo: Object, VCSRealmObject {
//    public typealias Model = VCSOwnerInfoResponse
//    
//    @Persisted(primaryKey: true) public var RealmID: String = "nil"
//    @Persisted var owner: String = ""
//    @Persisted var ownerEmail: String = ""
//    @Persisted var ownerName: String = ""
//    @Persisted var uploadPrefix: String = ""
//    @Persisted public var hasJoined: Bool = false
//    @Persisted var permission: List<String> = List()
//    @Persisted var dateCreated: String = ""
//    @Persisted var sharedParentFolder: String = ""
//    @Persisted var mountPoint: RealmMountPoint?
//    
//    
//    public required convenience init(model: Model) {
//        self.init()
//        
//        self.RealmID = model.realmID
//        self.owner = model.owner
//        self.ownerEmail = model.ownerEmail
//        self.ownerName = model.ownerName
//        self.uploadPrefix = model.uploadPrefix
//        self.dateCreated = model.dateCreated ?? ""
//        self.sharedParentFolder = model.sharedParentFolder
//        if let mountPoint = model.mountPoint {
//            mountPoint.modelID = self.RealmID
//            self.mountPoint = RealmMountPoint(model: mountPoint)
//        }
//        
//        let realmPermissionArray = List<String>()
//        model.permission.map { $0.rawValue }.forEach {
//            realmPermissionArray.append($0)
//        }
//        
//        self.permission = realmPermissionArray
//    }
//    
//    public var entity: Model {
//        let permissionArray = self.permission.compactMap({ $0 })
//        let arrPermission = Array(permissionArray)
//        
//        return VCSOwnerInfoResponse(owner: self.owner, ownerEmail: self.ownerEmail, ownerName: self.ownerName, uploadPrefix: self.uploadPrefix, hasJoined: self.hasJoined, permission: arrPermission, dateCreated: self.dateCreated, sharedParentFolder: self.sharedParentFolder, mountPoint: self.mountPoint?.entity, realmID: self.RealmID)
//    }
//    
//    public var partialUpdateModel: [String : Any] {
//        var result: [String : Any] = [:]
//        
//        result["RealmID"] = self.RealmID
//        result["owner"] = self.owner
//        result["ownerEmail"] = self.ownerEmail
//        result["ownerName"] = self.ownerName
//        result["uploadPrefix"] = self.uploadPrefix
//        result["dateCreated"] = self.dateCreated
//        result["sharedParentFolder"] = self.sharedParentFolder
//        result["mountPoint"] = self.mountPoint?.partialUpdateModel
//        result["permission"] = Array(self.permission.compactMap({ $0 }))
//        
//        return result
//    }
//}
