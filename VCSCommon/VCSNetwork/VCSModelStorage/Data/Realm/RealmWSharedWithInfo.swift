import Foundation
import RealmSwift

public class RealmWSharedWithInfo: Object, VCSRealmObject {
    public typealias Model = WSharedWithInfo
    override public class func primaryKey() -> String? { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var email: String = ""
    @objc dynamic var login: String = ""
    @objc dynamic var username: String = ""
    dynamic var permissions: List<String> = List()
    @objc dynamic var hasJoined: Bool = false
    
    public required convenience init(model: Model) {
        self.init()
        self.RealmID = model.login
        self.email = model.email
        self.login = model.login
        self.username = model.username
        self.hasJoined = model.hasJoined
        
        let modelArray = model.permissions
        let realmArray = List<String>()
        modelArray.forEach { realmArray.append($0) }
        self.permissions = realmArray
    }
    
    public var entity: WSharedWithInfo {
        let modelArray = self.permissions.compactMap({ $0 })
        let arr = Array(modelArray)
        
        return WSharedWithInfo(email: self.email, login: self.login, username: self.username, permissions: arr, hasJoined: self.hasJoined)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["email"] = self.email
        result["login"] = self.login
        result["username"] = self.username
        result["hasJoined"] = self.hasJoined
        result["permissions"] = Array(self.permissions.compactMap({ $0 }))
        
        return result
    }
}
