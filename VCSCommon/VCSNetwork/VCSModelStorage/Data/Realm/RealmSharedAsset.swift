import Foundation
import Realm
import RealmSwift

public class RealmSharedAsset: Object, VCSRealmObject {
    public typealias Model = VCSSharedAssetWrapper
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var asset: RealmSharedFileFolderAssetWrapper?
    @objc dynamic var assetType: String = AssetType.file.rawValue
    @objc dynamic var resourceURI: String = ""
    
    required convenience public init(model: Model) {
        self.init()
        
        self.RealmID = model.resourceURI
        self.asset = RealmSharedFileFolderAssetWrapper(model: model.asset)
        self.assetType = model.assetType.rawValue
        self.resourceURI = model.resourceURI
    }
    
    public var entity: Model {
        return VCSSharedAssetWrapper(asset: self.asset!.entity, assetType: AssetType.init(rawValue: self.assetType), resourceURI: self.resourceURI)
        
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["asset"] = self.asset?.partialUpdateModel
        result["assetType"] = self.assetType
        result["resourceURI"] = self.resourceURI
        
        return result
    }
}
