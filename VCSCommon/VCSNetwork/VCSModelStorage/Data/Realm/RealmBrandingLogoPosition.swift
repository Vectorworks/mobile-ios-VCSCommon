import Foundation
import RealmSwift

public class RealmBrandingLogoPosition: Object, VCSRealmObject {
    public typealias Model = BrandingLogoPosition
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    
    @Persisted var top: Double = 0
    @Persisted var left: Double = 0
    @Persisted var logoAR: Double = 0
    
    
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
