import Foundation
import RealmSwift

public class RealmVCSUser: Object, VCSRealmObject {
    public typealias Model = VCSUser
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted var allowedLanguages: String = ""
    @Persisted var awskeys: RealmVCSAWSkeys?
    @Persisted var email: String = ""
    @Persisted var firstName: String = ""
    @Persisted var groups: List<String> = List()
    @Persisted var isVSS: Bool = false
    @Persisted var language: String = ""
    @Persisted var lastName: String = ""
    @Persisted var nvwuid: String = ""
    @Persisted var preferences: String?
    @Persisted var quotas: RealmQuotas?
    @Persisted var resourceURI: String = ""
    @Persisted var username: String = ""
    @Persisted public var isLoggedIn: Bool = false
    @Persisted var storages: List<VCSRealmStorage> = List<VCSRealmStorage>()
    
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
        
        let partialsStorages = Array(self.storages.compactMap({ $0.partialUpdateModel }))
        if partialsStorages.count > 1 {
            result["storages"] = partialsStorages
        }
        
        return result
    }
}
