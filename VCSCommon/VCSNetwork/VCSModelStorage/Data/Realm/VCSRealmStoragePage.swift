import Foundation
import RealmSwift

public class VCSRealmStoragPages: Object, VCSRealmObject {
    public typealias Model = StoragePage
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic public var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var folderURI: String = ""
    dynamic var sharedPaths: List<String> = List()
    
    public required convenience init(model: StoragePage) {
        self.init()
        self.RealmID = model.folderURI
        self.id = model.id
        self.name = model.name
        self.folderURI = model.folderURI
        let realmSharedPathsArray = List<String>()
        model.sharedPaths?.forEach {
            realmSharedPathsArray.append($0)
        }
        self.sharedPaths = realmSharedPathsArray
    }
    
    public var entity: StoragePage {
        let sharedPathsArray = self.sharedPaths.compactMap({ $0 })
        let arrSharedPaths = Array(sharedPathsArray)
        return StoragePage(id: self.id, name: self.name, folderURI: self.folderURI, sharedPaths: arrSharedPaths)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["id"] = self.id
        result["name"] = self.name
        result["folderURI"] = self.folderURI
        result["sharedPaths"] = Array(self.sharedPaths.compactMap({ $0 }))
        
        return result
    }
}
