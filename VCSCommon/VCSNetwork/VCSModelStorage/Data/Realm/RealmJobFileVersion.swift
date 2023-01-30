import Foundation
import RealmSwift

public class RealmJobFileVersion: Object, VCSRealmObject {
    public typealias Model = VCSJobFileVersionResponse
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic public var id: Int = 0
    @objc dynamic var owner: String = ""
    @objc dynamic var container: String = ""
    @objc dynamic var provider: String = ""
    @objc dynamic var fileType: String = ""
    @objc dynamic var path: String = ""
    @objc dynamic var versionID: String = ""
    @objc dynamic var resourceID: String = ""
    
    
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
