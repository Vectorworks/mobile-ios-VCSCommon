//import Foundation
//import RealmSwift
//
//public class RealmSharingInfo: Object, VCSRealmObject {
//    public typealias Model = VCSSharingInfoResponse
//    
//    @Persisted(primaryKey: true) public var RealmID: String = "nil"
//    @Persisted var isShared: Bool = false
//    @Persisted var link: String = ""
//    @Persisted var linkUUID: String = ""
//    @Persisted var linkExpires: String = ""
//    @Persisted var linkVisitsCount: Int = 0
//    @Persisted var allowComments: Bool = false
//    
//    @Persisted var sharedWith: List<RealmSharedWithUser> = List()
//    @Persisted var resourceURI: String = ""
//    @Persisted var lastShareDate: String?
//    
//    public required convenience init(model: Model) {
//        self.init()
//        
//        self.RealmID = model.realmID
//        self.isShared = model.isShared
//        self.link = model.link
//        self.linkUUID = model.linkUUID
//        self.linkExpires = model.linkExpires
//        self.linkVisitsCount = model.linkVisitsCount
//        self.allowComments = model.allowComments
//        
//        let realmSharedWithArray = List<RealmSharedWithUser>()
//        model.sharedWith?.forEach {
//            realmSharedWithArray.append(RealmSharedWithUser(model: $0))
//        }
//        self.sharedWith = realmSharedWithArray
//        self.resourceURI = model.resourceURI
//        self.lastShareDate = model.lastShareDate
//    }
//    
//    public var entity: VCSSharingInfoResponse {
//        let sharedWithArray = self.sharedWith.compactMap({ $0.entity })
//        let arrSharedWith = Array(sharedWithArray)
//        
//        return VCSSharingInfoResponse(isShared: self.isShared, link: self.link, linkUUID: self.linkUUID, linkExpires: self.linkExpires, allowComments: self.allowComments, sharedWith: arrSharedWith, resourceURI: self.resourceURI, lastShareDate: self.lastShareDate, realmID: self.RealmID)
//    }
//    
//    public var partialUpdateModel: [String : Any] {
//        var result: [String : Any] = [:]
//        
//        result["RealmID"] = self.RealmID
//        result["isShared"] = self.isShared
//        result["link"] = self.link
//        result["linkUUID"] = self.linkUUID
//        result["linkExpires"] = self.linkExpires
//        result["linkVisitsCount"] = self.linkVisitsCount
//        result["allowComments"] = self.allowComments
//        
//        
//        result["sharedWith"] = Array(self.sharedWith.compactMap({ $0.partialUpdateModel }))
//        result["resourceURI"] = self.resourceURI
//        result["lastShareDate"] = self.lastShareDate
//        
//        return result
//    }
//}
