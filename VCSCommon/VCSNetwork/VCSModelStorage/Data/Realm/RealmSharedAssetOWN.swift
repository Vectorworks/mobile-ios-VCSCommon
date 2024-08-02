//import Foundation
//import Realm
//import RealmSwift
//
//public class RealmSharedAssetOWN: Object, VCSRealmObject {
//    public typealias Model = VCSSharedAssetOWNResponse
//    
//    @Persisted(primaryKey: true) public var RealmID: String = "nil"
//    @Persisted var asset: RealmSharedFileFolderAssetWrapper?
//    @Persisted var assetType: String = AssetType.file.rawValue
//    @Persisted var resourceURI: String = ""
//    
//    @Persisted var owner: String = ""
//    @Persisted var ownerEmail: String = ""
//    @Persisted var ownerName: String = ""
//    @Persisted var dateCreated: String = ""
//    
//    required convenience public init(model: Model) {
//        self.init()
//        
//        self.RealmID = model.resourceURI
//        self.asset = RealmSharedFileFolderAssetWrapper(model: model.asset)
//        self.assetType = model.assetType.rawValue
//        self.resourceURI = model.resourceURI
//        
//        self.owner = model.owner
//        self.ownerEmail = model.ownerEmail
//        self.ownerName = model.ownerName
//        self.dateCreated = model.dateCreated
//    }
//    
//    public var entity: Model {
//        return VCSSharedAssetOWNResponse(owner: self.owner, ownerEmail: self.ownerEmail, ownerName: self.ownerName, dateCreated: self.dateCreated,
//                              asset: self.asset!.entity, assetType: AssetType.init(rawValue: self.assetType), resourceURI: self.resourceURI)
//        
//    }
//    
//    public var partialUpdateModel: [String : Any] {
//        var result: [String : Any] = [:]
//        
//        result["RealmID"] = self.RealmID
//        result["asset"] = self.asset?.partialUpdateModel
//        result["assetType"] = self.assetType
//        result["resourceURI"] = self.resourceURI
//        result["owner"] = self.owner
//        result["ownerEmail"] = self.ownerEmail
//        result["ownerName"] = self.ownerName
//        result["dateCreated"] = self.dateCreated
//        
//        return result
//    }
//}
