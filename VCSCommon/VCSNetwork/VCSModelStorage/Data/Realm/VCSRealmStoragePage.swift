import Foundation
import RealmSwift

public class VCSRealmStoragPages: Object, VCSRealmObject {
    public typealias Model = StoragePage
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var folderURI: String = ""
    
    public required convenience init(model: StoragePage) {
        self.init()
        self.RealmID = model.folderURI
        self.id = model.id
        self.name = model.name
        self.folderURI = model.folderURI
    }
    
    public var entity: StoragePage {
        return StoragePage(id: self.id, name: self.name, folderURI: self.folderURI)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["id"] = self.id
        result["name"] = self.name
        result["folderURI"] = self.folderURI
        
        return result
    }
}
