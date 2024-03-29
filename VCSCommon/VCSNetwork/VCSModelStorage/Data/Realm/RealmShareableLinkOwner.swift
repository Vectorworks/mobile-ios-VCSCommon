import Foundation
import Realm
import RealmSwift

public class RealmShareableLinkOwner: Object, VCSRealmObject {
    public typealias Model = VCSShareableLinkOwner
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted var ownerEmail: String = ""
    @Persisted var ownerName: String = ""
    
    @Persisted var branding: RealmSharedAssetBranding?
    
    required convenience public init(model: Model) {
        self.init()
        self.RealmID = model.owner
        self.ownerEmail = model.ownerEmail
        self.ownerName = model.ownerName
        
        model.branding.realmID = self.RealmID
        self.branding = RealmSharedAssetBranding(model: model.branding)
    }
    
    public var entity: Model {
        return VCSShareableLinkOwner(branding: self.branding!.entity, owner: self.RealmID, ownerEmail: self.ownerEmail, ownerName: self.ownerName)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["ownerEmail"] = self.ownerEmail
        result["ownerName"] = self.ownerName
        
        if let branding = self.branding {
            result["branding"] = branding.partialUpdateModel
        }
        
        return result
    }
}
