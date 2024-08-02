//import Foundation
//import RealmSwift
//
//class RealmEmail: Object, VCSRealmObject {
//    typealias Model = Email
//    
//    @Persisted(primaryKey: true) var RealmID: String = "nil"
//    @Persisted var email: String = ""
//    @Persisted var isVerified: Bool = false
//    
//    required convenience init(model: Model) {
//        self.init()
//        self.RealmID = model.email
//        self.email = model.email
//        self.isVerified = model.isVerified
//    }
//    
//    var entity: Email {
//        return Email(email: self.email, isVerified: self.isVerified)
//    }
//    
//    var partialUpdateModel: [String : Any] {
//        let model: [String : Any] = [
//            "RealmID" : self.RealmID
//            , "email" : self.email
//            , "isVerified" : self.isVerified
//        ]
//        
//        return model
//    }
//}
