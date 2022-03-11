import Foundation
import Realm
import RealmSwift


public class RealmSharedWithMeAsset: Object, VCSRealmObject {
    public typealias Model = VCSSharedWithMeAsset
    override public class func primaryKey() -> String? { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var asset: RealmSharedWithMeAssetWrapper?
    @objc dynamic var assetType: String = AssetType.file.rawValue
    @objc dynamic var owner: String = ""
    @objc dynamic var ownerEmail: String = ""
    @objc dynamic var ownerName: String = ""
    @objc dynamic var dateCreated: String = ""
    dynamic var permission: List<String> = List()
    @objc dynamic var sharedParentFolder: String = ""
    @objc dynamic var sharedWithLogin: String?
    
    public required convenience init(model: Model) {
        self.init()
        
        self.asset = RealmSharedWithMeAssetWrapper(model: model.asset)
        self.RealmID = model.asset.rID
        
        self.assetType = model.assetType.rawValue
        self.owner = model.owner
        self.ownerName = model.ownerName
        self.ownerEmail = model.ownerEmail
        self.dateCreated = model.dateCreated
        self.sharedParentFolder = model.sharedParentFolder
        self.sharedWithLogin = model.sharedWithLogin
        
        let realmPermissionArray = List<String>()
        model.permission.map { $0.rawValue }.forEach {
            realmPermissionArray.append($0)
        }
        
        self.permission = realmPermissionArray
    }
    
    public var entity: Model {
        let permissionArray = self.permission.compactMap({ $0 })
        let arrPermission = Array(permissionArray)
        
        return VCSSharedWithMeAsset(owner: self.owner, ownerEmail: self.ownerEmail, ownerName: self.ownerName, dateCreated: self.dateCreated, asset: self.asset!.entity, assetType: AssetType(rawValue: self.assetType), resourceURI: self.RealmID, permission: arrPermission, sharedParentFolder: self.sharedParentFolder, sharedWithLogin: self.sharedWithLogin)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["asset"] = self.asset?.partialUpdateModel
        result["assetType"] = self.assetType
        result["resourceURI"] = self.RealmID
        result["owner"] = self.owner
        result["ownerEmail"] = self.ownerEmail
        result["ownerName"] = self.ownerName
        result["dateCreated"] = self.dateCreated
        result["permission"] = self.permission
        result["sharedParentFolder"] = self.sharedParentFolder
        result["sharedWithLogin"] = self.sharedWithLogin
        
        return result
    }
}
