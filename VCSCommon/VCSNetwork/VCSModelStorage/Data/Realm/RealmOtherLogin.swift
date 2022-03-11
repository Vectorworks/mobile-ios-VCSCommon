import Foundation
import RealmSwift

class RealmOtherLogin: Object, VCSRealmObject {
    typealias Model = OtherLogin
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic var RealmID: String = "nil"
    @objc dynamic var id: Int = 0
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var isActive: Bool = false
    @objc dynamic var login: String = ""
    @objc dynamic var nvwuid: String = ""
    @objc dynamic var gender: String = ""
    @objc dynamic var industry, phone: String?
    @objc dynamic var honorific: String = ""
    @objc dynamic var language: String = ""
    @objc dynamic var sourceSystem: String = ""
        
    required convenience init(model: Model) {
        self.init()
        self.RealmID = "\(model.id)"
        self.id = model.id
        self.firstName = model.firstName
        self.lastName = model.lastName
        self.email = model.email
        self.isActive = model.isActive
        self.nvwuid = model.nvwuid
        self.gender = model.gender
        self.industry = model.industry
        self.phone = model.phone
        self.honorific = model.honorific
        self.language = model.language
        self.sourceSystem = model.sourceSystem
    }
    
    var entity: OtherLogin {
        return OtherLogin(id: self.id, firstName: self.firstName, lastName: self.lastName, email: self.email, isActive: self.isActive, login: self.login, nvwuid: self.nvwuid, gender: self.gender, industry: self.industry, phone: self.phone, honorific: self.honorific, language: self.language, sourceSystem: self.sourceSystem)
    }
    
    var partialUpdateModel: [String : Any] {
        let model: [String : Any] = [
            "RealmID" : self.RealmID
            , "id" : self.id
            , "firstName" : self.firstName
            , "lastName" : self.lastName
            , "email" : self.email
            , "isActive" : self.isActive
            , "nvwuid" : self.nvwuid
            , "gender" : self.gender
            , "industry" : self.industry ?? ""
            , "phone" : self.phone ?? ""
            , "honorific" : self.honorific
            , "language" : self.language
            , "sourceSystem" : self.sourceSystem
        ]
        
        return model
    }
}
