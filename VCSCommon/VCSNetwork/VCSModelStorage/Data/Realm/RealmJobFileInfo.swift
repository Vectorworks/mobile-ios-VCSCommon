import Foundation
import RealmSwift

public class RealmJobFileInfo: Object, VCSRealmObject {
    public typealias Model = VCSJobFileInfoResponse
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic public var fileCount: Int = 0
    @objc dynamic var path: String = ""
    @objc dynamic var provider: String = ""
    
    
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
