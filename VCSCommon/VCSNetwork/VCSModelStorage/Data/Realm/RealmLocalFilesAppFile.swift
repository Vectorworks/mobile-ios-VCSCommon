import Foundation
import RealmSwift

public class RealmLocalFilesAppFile: Object, VCSRealmObject {
    public typealias Model = LocalFilesAppFile
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted var pathSuffix: String = ""
    
    public required convenience init(model: Model) {
        self.init()
        self.RealmID = model.VCSID
        self.pathSuffix = model.pathSuffix
    }
    
    
    public var entity: Model {
        return LocalFilesAppFile(VCSID: self.RealmID, pathSuffix: self.pathSuffix)//, lastModified: self.lastModified)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["pathSuffix"] = self.pathSuffix
        
        return result
    }
}
