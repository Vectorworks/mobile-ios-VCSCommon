import Foundation
import RealmSwift

public class RealmJobFileVersion: Object, VCSRealmObject {
    public typealias Model = VCSJobFileVersionResponse
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted public var id: Int = 0
    @Persisted var owner: String = ""
    @Persisted var container: String = ""
    @Persisted var provider: String = ""
    @Persisted var fileType: String = ""
    @Persisted var path: String = ""
    @Persisted var versionID: String = ""
    @Persisted var resourceID: String = ""
    
    
    public required convenience init(model: Model) {
        self.init()
        
        self.RealmID = model.VCSID
        self.id = model.id
        self.owner = model.owner
        self.container = model.container
        self.provider = model.provider
        self.fileType = model.fileType
        self.path = model.path
        self.versionID = model.versionID
        self.resourceID = model.resourceID
    }
    
    public var entity: Model {
        return VCSJobFileVersionResponse(VCSID: self.RealmID, id: self.id, owner: self.owner, container: self.container, provider: self.provider, fileType: self.fileType, path: self.path, versionID: self.versionID, resourceID: self.resourceID)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["id"] = self.id
        result["owner"] = self.owner
        result["container"] = self.container
        result["provider"] = self.provider
        result["fileType"] = self.fileType
        result["path"] = self.path
        result["versionID"] = self.versionID
        result["resourceID"] = self.resourceID
        
        return result
    }
}
