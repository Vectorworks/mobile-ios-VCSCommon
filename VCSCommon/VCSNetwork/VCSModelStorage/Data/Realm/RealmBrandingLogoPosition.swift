import Foundation
import RealmSwift

public class RealmBrandingLogoPosition: Object, VCSRealmObject {
    public typealias Model = BrandingLogoPosition
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    
    @objc dynamic var top: Double = 0
    @objc dynamic var left: Double = 0
    @objc dynamic var logoAR: Double = 0
    
    
    public required convenience init(model: Model) {
        self.init()
        if let rID = model.realmID {
            self.RealmID = rID
        }
        
        self.top = model.top
        self.left = model.left
        self.logoAR = model.logoAR
    }
    
    public var entity: Model {
        return BrandingLogoPosition(top: self.top, left: self.left, logoAR: self.logoAR, realmID: self.RealmID)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["top"] = self.top
        result["left"] = self.left
        result["logoAR"] = self.logoAR
        
        return result
    }
}
