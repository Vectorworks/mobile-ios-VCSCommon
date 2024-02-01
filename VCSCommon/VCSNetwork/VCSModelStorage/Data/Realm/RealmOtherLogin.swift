import Foundation
import RealmSwift

class RealmOtherLogin: Object, VCSRealmObject {
    typealias Model = OtherLogin
    
    @Persisted(primaryKey: true) var RealmID: String = "nil"
    @Persisted var id: Int = 0
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var email: String = ""
    @Persisted var isActive: Bool = false
    @Persisted var login: String = ""
    @Persisted var nvwuid: String = ""
    @Persisted var gender: String = ""
    @Persisted var industry: String?
    @Persisted var phone: String?
    @Persisted var honorific: String = ""
    @Persisted var language: String = ""
    @Persisted var sourceSystem: String = ""
        
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
