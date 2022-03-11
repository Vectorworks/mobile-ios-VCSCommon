import Foundation
import Realm
import RealmSwift

public class RealmSharedAssetOWN: Object, VCSRealmObject {
    public typealias Model = VCSSharedAssetOWNResponse
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var asset: RealmSharedFileFolderAssetWrapper?
    @objc dynamic var assetType: String = AssetType.file.rawValue
    @objc dynamic var resourceURI: String = ""
    
    @objc dynamic var owner: String = ""
    @objc dynamic var ownerEmail: String = ""
    @objc dynamic var ownerName: String = ""
    @objc dynamic var dateCreated: String = ""
    
    required convenience public init(model: Model) {
        self.init()
        
        self.RealmID = model.resourceURI
        self.asset = RealmSharedFileFolderAssetWrapper(model: model.asset)
        self.assetType = model.assetType.rawValue
        self.resourceURI = model.resourceURI
        
        self.owner = model.owner
        self.ownerEmail = model.ownerEmail
        self.ownerName = model.ownerName
        self.dateCreated = model.dateCreated
    }
    
    public var entity: Model {
        return VCSSharedAssetOWNResponse(owner: self.owner, ownerEmail: self.ownerEmail, ownerName: self.ownerName, dateCreated: self.dateCreated,
                              asset: self.asset!.entity, assetType: AssetType.init(rawValue: self.assetType), resourceURI: self.resourceURI)
        
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
        
        return result
    }
}
