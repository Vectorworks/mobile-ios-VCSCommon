import Foundation
import Realm
import RealmSwift


public class RealmSharedWithMeAssetWrapper: Object, VCSRealmObject {
    public typealias Model = Asset
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var fileAsset: RealmFile?
    @objc dynamic var folderAsset: RealmFolder?
    
    
    public required convenience init(model: Model) {
        self.init()
        if model.isFolder, let folder = model as? VCSFolderResponse {
            self.folderAsset = RealmFolder(model: folder)
            self.RealmID = self.folderAsset!.RealmID
        }
        if model.isFile, let file = model as? VCSFileResponse {
            self.fileAsset = RealmFile(model: file)
            self.RealmID = self.fileAsset!.RealmID
        }
    }
    
    public var entity: Asset {
        if self.fileAsset != nil {
            return self.fileAsset!.entity
        }
        if self.folderAsset != nil {
            return self.folderAsset!.entity
        }
        
        return RealmFile().entity
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        if let fileAsset = self.fileAsset {
            result["fileAsset"] = fileAsset.partialUpdateModel
            result["RealmID"] = fileAsset.RealmID
        }
        if let folderAsset = self.folderAsset {
            result["folderAsset"] = folderAsset.partialUpdateModel
            result["RealmID"] = folderAsset.RealmID
        }
        
        return result
    }
}
