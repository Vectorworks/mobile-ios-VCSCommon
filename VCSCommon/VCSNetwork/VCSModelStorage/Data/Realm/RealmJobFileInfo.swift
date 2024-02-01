import Foundation
import RealmSwift

public class RealmJobFileInfo: Object, VCSRealmObject {
    public typealias Model = VCSJobFileInfoResponse
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted public var fileCount: Int = 0
    @Persisted var path: String = ""
    @Persisted var provider: String = ""
    
    
    public required convenience init(model: Model) {
        self.init()
        
        self.RealmID = model.path
        self.fileCount = model.fileCount
        self.path = model.path
        self.provider = model.provider
    }
    
    public var entity: Model {
        return VCSJobFileInfoResponse(fileCount: self.fileCount, path: self.path, provider: self.provider)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["fileCount"] = self.fileCount
        result["path"] = self.path
        result["provider"] = self.provider
        
        return result
    }
}
