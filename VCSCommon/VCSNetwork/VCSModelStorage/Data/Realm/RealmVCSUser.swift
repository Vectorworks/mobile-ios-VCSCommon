import Foundation
import RealmSwift

public class RealmVCSUser: Object, VCSRealmObject {
    public typealias Model = VCSUser
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var allowedLanguages: String = ""
    @objc dynamic var awskeys: RealmVCSAWSkeys?
    @objc dynamic var email: String = ""
    @objc dynamic var firstName: String = ""
    dynamic var groups: List<String> = List()
    @objc dynamic var isVSS: Bool = false
    @objc dynamic var language: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var nvwuid: String = ""
    @objc dynamic var preferences: String?
    @objc dynamic var quotas: RealmQuotas?
    @objc dynamic var resourceURI: String = ""
    @objc dynamic var username: String = ""
    @objc dynamic var isLoggedIn: Bool = false
    dynamic var storages: List<VCSRealmStorage> = List<VCSRealmStorage>()
    
    public required convenience init(model: Model) {
        self.init()
        self.RealmID = model.login
        self.allowedLanguages = model.allowedLanguages
        self.awskeys = RealmVCSAWSkeys(model: model.awskeys)
        self.email = model.email
        self.firstName = model.firstName
        self.isVSS = model.isVSS
        self.language = model.language
        self.lastName = model.lastName
        self.nvwuid = model.nvwuid
        self.preferences = model.preferences
        self.quotas = RealmQuotas(model: model.quotas)
        self.resourceURI = model.resourceURI
        self.username = model.username
        self.isLoggedIn = model.isLoggedIn
        
        let groupsArray = model.groups
        let realmGroupsArray = List<String>()
        groupsArray.forEach { realmGroupsArray.append($0) }
        self.groups = realmGroupsArray
        
        let realmStorageArray = List<VCSRealmStorage>()
        model.storages.forEach { realmStorageArray.append(VCSRealmStorage(model:$0)) }
        self.storages = realmStorageArray
    }
    
    public var entity: Model {
        let groupsArray = Array(self.groups.compactMap({ $0 }))
        let storages = Array(self.storages.compactMap({ $0.entity }))
        return VCSUser(allowedLanguages: self.allowedLanguages, awskeys: self.awskeys!.entity, email: self.email, firstName: self.firstName, groups: groupsArray, isVSS: self.isVSS, language: self.language, lastName: self.lastName, login: self.RealmID, nvwuid: self.nvwuid, preferences: self.preferences, quotas: self.quotas!.entity, resourceURI: self.resourceURI, username: self.username, storages: storages, isLoggedIn: self.isLoggedIn)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["allowedLanguages"] = self.allowedLanguages
        result["email"] = self.email
        result["firstName"] = self.firstName
        result["groups"] = self.groups
        result["isVSS"] = self.isVSS
        result["language"] = self.language
        result["lastName"] = self.lastName
        result["nvwuid"] = self.nvwuid
        result["preferences"] = self.preferences
        result["quotas"] = self.quotas
        result["resourceURI"] = self.resourceURI
        result["username"] = self.username
        result["isLoggedIn"] = self.isLoggedIn
        
        if let awskeys = self.awskeys {
            result["awskeys"] = awskeys.partialUpdateModel
        }
        
        return result
    }
}
