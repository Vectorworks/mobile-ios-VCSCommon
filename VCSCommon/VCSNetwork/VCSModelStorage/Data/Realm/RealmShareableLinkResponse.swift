import Foundation
import Realm
import RealmSwift

public class RealmShareableLinkResponse: Object, VCSRealmObject {
    public typealias Model = VCSShareableLinkResponse
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var dateCreated: String = ""
    @objc dynamic var link: String = ""
    @objc dynamic var resourceURI: String = ""
    @objc dynamic var expires: String = ""
    
    @objc dynamic var asset: RealmSharedFileFolderAssetWrapper?
    @objc dynamic var assetType: String = AssetType.file.rawValue
    @objc dynamic var owner: RealmShareableLinkOwner?
    
    required convenience public init(model: Model) {
        self.init()
        
        self.RealmID = model.asset.resourceID
        self.dateCreated = model.dateCreated
        self.link = model.link
        self.resourceURI = model.resourceURI
        self.expires = model.expires
        
        self.asset = RealmSharedFileFolderAssetWrapper(model: model.asset)
        self.assetType = model.assetType.rawValue
        self.owner = RealmShareableLinkOwner(model: model.owner)
    }
    
    public var entity: Model {
        return VCSShareableLinkResponse(link: self.link, uuid: self.RealmID, expires: self.expires, owner: self.owner!.entity, dateCreated: self.dateCreated, asset: self.asset!.entity, assetType: AssetType(rawValue: self.assetType), resourceURI: self.resourceURI)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["assetType"] = self.assetType
        result["resourceURI"] = self.resourceURI
        result["dateCreated"] = self.dateCreated
        result["link"] = self.link
        result["expires"] = self.expires
        
        if let asset = self.asset {
            let partialModel = asset.partialUpdateModel
            if partialModel.count > 0 {
                result["asset"] = partialModel
            }
        }
        
        if let owner = self.owner {
            result["owner"] = owner.partialUpdateModel
        }
        
        return result
    }
}
