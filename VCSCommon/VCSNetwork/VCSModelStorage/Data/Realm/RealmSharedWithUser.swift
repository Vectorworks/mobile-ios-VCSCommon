//import Foundation
//import RealmSwift
//
//public class RealmSharedWithUser: Object, VCSRealmObject {
//    public typealias Model = VCSSharedWithUser
//    
//    @Persisted(primaryKey: true) public var RealmID: String = "nil"
//    @Persisted public var login: String?
//    @Persisted public var username: String?
//    @Persisted public var hasJoined: Bool = false
//    
//    dynamic public var permissions: List<String> = List()
//    
//    public required convenience init(model: Model) {
//        self.init()
//        self.RealmID = model.email
//        self.login = model.login
//        self.username = model.username
//        self.hasJoined = model.hasJoined
//        
//        let realmPermissionsArray = List<String>()
//        model.permissions.forEach {
//            realmPermissionsArray.append($0)
//        }
//        
//        self.permissions = realmPermissionsArray
//    }
//    
//    public var entity: VCSSharedWithUser {
//        let permissionsArray = self.permissions.compactMap({ $0 })
//        let arrPermissions = Array(permissionsArray)
//        
//        return VCSSharedWithUser(email: self.RealmID, login: self.login, username: self.username, hasJoined: self.hasJoined, permissions: arrPermissions)
//    }
//    
//    public var partialUpdateModel: [String : Any] {
//        var result: [String : Any] = [:]
//        
//        result["RealmID"] = self.RealmID
//        result["login"] = self.login
//        result["username"] = self.username
//        result["permissions"] = self.permissions
//        result["hasJoined"] = self.hasJoined
//        
//        return result
//    }
//}
