import Foundation
import Realm
import RealmSwift


public class RealmSharedWithMeAsset: Object, RealmAssetWrapperWithSorting, VCSRealmObject {
    public typealias Model = VCSSharedWithMeAsset
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted var asset: RealmSharedWithMeAssetWrapper?
    @Persisted var assetType: String = AssetType.file.rawValue
    @Persisted var resourceURI: String = ""
    @Persisted var owner: String = ""
    @Persisted var ownerEmail: String = ""
    @Persisted var ownerName: String = ""
    @Persisted var dateCreated: String = ""
    @Persisted var permission: List<String> = List()
    @Persisted var sharedParentFolder: String = ""
    @Persisted var sharedWithLogin: String?
    @Persisted var branding: RealmSharedAssetBranding?
    
    public var fakeRealmID: String { return RealmID }
    public var fakeSortingName: String { return asset?.fileAsset?.name ?? asset?.folderAsset?.name ?? "" }
    public var fakeSortingDate: Date { return self.dateCreated.VCSDateFromISO8061 ?? Date() }
    public var fakeSortingSize: String { return asset?.fileAsset?.size ?? "0"}
    public var fakeFilterShowingOffline: Bool { return self.isAvailableOnDevice }
    private var isAvailableOnDevice: Bool { return self.asset?.isAvailableOnDevice ?? false }
    
    public required convenience init(model: Model) {
        self.init()
        
        self.asset = RealmSharedWithMeAssetWrapper(model: model.asset)
        self.RealmID = model.asset.rID
        
        self.assetType = model.assetType.rawValue
        self.resourceURI = model.resourceURI
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
        if let modelBranding = model.branding {
            modelBranding.realmID = self.RealmID
            self.branding = RealmSharedAssetBranding(model: modelBranding)
        }
    }
    
    public var entity: Model {
        let permissionArray = self.permission.compactMap({ $0 })
        let arrPermission = Array(permissionArray)
        
        return VCSSharedWithMeAsset(owner: self.owner, ownerEmail: self.ownerEmail, ownerName: self.ownerName, dateCreated: self.dateCreated, asset: self.asset!.entity, assetType: AssetType(rawValue: self.assetType), resourceURI: self.resourceURI, permission: arrPermission, sharedParentFolder: self.sharedParentFolder, sharedWithLogin: self.sharedWithLogin, branding: self.branding?.entity)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["asset"] = self.asset?.partialUpdateModel
        result["assetType"] = self.assetType
        result["resourceURI"] = self.resourceURI
        result["owner"] = self.owner
        result["ownerEmail"] = self.ownerEmail
        result["ownerName"] = self.ownerName
        result["dateCreated"] = self.dateCreated
        result["permission"] = self.permission
        result["sharedParentFolder"] = self.sharedParentFolder
        result["sharedWithLogin"] = self.sharedWithLogin
        
        if let branding = self.branding {
            result["branding"] = branding.partialUpdateModel
        }
        
        return result
    }
}
