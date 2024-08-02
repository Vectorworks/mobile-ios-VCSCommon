//import Foundation
//import RealmSwift
//
//public class RealmSharedAssetBranding: Object, VCSRealmObject {
//    public typealias Model = VCSSharedAssetBrandingResponse
//    
//    @Persisted(primaryKey: true) public var RealmID: String = "nil"
//    @Persisted var position: RealmBrandingLogoPosition?
//    @Persisted var image: String?
//    @Persisted var opacity: Float?
//    @Persisted var size: Float?
//    
//    
//    public required convenience init(model: Model) {
//        self.init()
//        if let realmID = model.realmID {
//            self.RealmID = realmID
//        }
//        if let position = model.position {
//            self.position = RealmBrandingLogoPosition(model: position)
//        }
//        self.image = model.image
//        self.opacity = model.opacity
//        self.size = model.size
//    }
//    
//    public var entity: Model {
//        return VCSSharedAssetBrandingResponse(position: self.position?.entity, image: self.image, opacity: self.opacity, size: self.size, realmID: self.RealmID)
//    }
//    
//    public var partialUpdateModel: [String : Any] {
//        var result: [String : Any] = [:]
//        
//        result["RealmID"] = self.RealmID
//        
//        if let position = self.position {
//            result["position"] = position.partialUpdateModel
//        }
//        
//        if let image = self.image {
//            result["image"] = image
//        }
//        
//        if let opacity = self.opacity {
//            result["opacity"] = opacity
//        }
//        
//        if let size = self.size {
//            result["size"] = size
//        }
//        
//        return result
//    }
//}
