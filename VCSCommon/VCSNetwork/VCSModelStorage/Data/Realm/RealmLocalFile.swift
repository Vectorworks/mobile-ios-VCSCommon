import Foundation
import RealmSwift

public class RealmLocalFile: Object, VCSRealmObject {
    public typealias Model = LocalFile
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted var name: String = ""
    @Persisted var parent: String = ""
    
    public var exists: Bool {
        return FileManager.default.fileExists(atPath: self.localPath)
    }
    
    public var localPath: String {
        let localFileName = self.RealmID.appendingPathExtension(self.name.pathExtension)
        let fileURL = FileManager.downloadPath(fileName: localFileName)
        return fileURL.path
    }
    
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
