import Foundation
import RealmSwift

public class RealmSharedAssetBranding: Object, VCSRealmObject {
    public typealias Model = VCSSharedAssetBrandingResponse
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"

    @objc dynamic var position: RealmBrandingLogoPosition?
    @objc dynamic var image: String?
    dynamic var opacity: RealmProperty<Float?> = RealmProperty<Float?>()
    dynamic var size: RealmProperty<Float?> = RealmProperty<Float?>()
    
    
    public required convenience init(model: Model) {
        self.init()
        if let realmID = model.realmID {
            self.RealmID = realmID
        }
        if let position = model.position {
            self.position = RealmBrandingLogoPosition(model: position)
        }
        self.image = model.image
        self.opacity.value = model.opacity
        self.size.value = model.size
    }
    
    public var entity: Model {
        return VCSSharedAssetBrandingResponse(position: self.position?.entity, image: self.image, opacity: self.opacity.value, size: self.size.value, realmID: self.RealmID)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        
        if let position = self.position {
            result["position"] = position
        }
        
        if let image = self.image {
            result["image"] = image
        }
        
        if let opacity = self.opacity.value {
            result["opacity"] = opacity
        }
        
        if let size = self.size.value {
            result["size"] = size
        }
        
        return result
    }
}
