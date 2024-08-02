//import Foundation
//import RealmSwift
//
//public class VCSRealmStoragPages: Object, VCSRealmObject {
//    public typealias Model = StoragePage
//    
//    @Persisted(primaryKey: true) public var RealmID: String = "nil"
//    @Persisted public var id: String = ""
//    @Persisted var name: String = ""
//    @Persisted var folderURI: String = ""
//    @Persisted var sharedPaths: List<String> = List()
//    
//    public required convenience init(model: StoragePage) {
//        self.init()
//        self.RealmID = model.folderURI
//        self.id = model.id
//        self.name = model.name
//        self.folderURI = model.folderURI
//        let realmSharedPathsArray = List<String>()
//        model.sharedPaths?.forEach {
//            realmSharedPathsArray.append($0)
//        }
//        self.sharedPaths = realmSharedPathsArray
//    }
//    
//    public var entity: StoragePage {
//        let sharedPathsArray = self.sharedPaths.compactMap({ $0 })
//        let arrSharedPaths = Array(sharedPathsArray)
//        return StoragePage(id: self.id, name: self.name, folderURI: self.folderURI, sharedPaths: arrSharedPaths)
//    }
//    
//    public var partialUpdateModel: [String : Any] {
//        var result: [String : Any] = [:]
//        
//        result["RealmID"] = self.RealmID
//        result["id"] = self.id
//        result["name"] = self.name
//        result["folderURI"] = self.folderURI
//        result["sharedPaths"] = Array(self.sharedPaths.compactMap({ $0 }))
//        
//        return result
//    }
//}
