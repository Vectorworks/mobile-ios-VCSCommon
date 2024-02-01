import Foundation
import RealmSwift

public class RealmLocalFile: Object, VCSRealmObject {
    public typealias Model = LocalFile
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted var name: String = ""
    @Persisted var parent: String = ""
    
    public required convenience init(model: Model) {
        self.init()
        self.RealmID = model.uuid
        
        self.name = model.name
        self.parent = model.parent
    }
    
    
    public var entity: LocalFile {
        return LocalFile(name: self.name, parent: self.parent, uuid: self.RealmID)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["name"] = self.name
        result["parent"] = self.parent
        
        return result
    }
}
