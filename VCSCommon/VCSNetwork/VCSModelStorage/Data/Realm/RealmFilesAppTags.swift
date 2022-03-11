import Foundation
import RealmSwift

public class RealmFilesAppTags: Object, VCSRealmObject {
    public typealias Model = VCSFilesAppTags
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var tagData: Data? = nil
    
    
    public required convenience init(model: Model) {
        self.init()
        
        self.RealmID = model.realmID
        self.tagData = model.tagData
    }
    
    public var entity: Model {
        return VCSFilesAppTags(tagData: self.tagData, realmID: self.RealmID)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["tagData"] = self.tagData
        
        return result
    }
}
