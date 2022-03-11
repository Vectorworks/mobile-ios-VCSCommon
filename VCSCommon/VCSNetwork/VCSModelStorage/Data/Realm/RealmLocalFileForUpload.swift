import Foundation
import RealmSwift

public class RealmLocalFileForUpload: Object, VCSRealmObject {
    public typealias Model = LocalFileForUpload
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    
    @objc dynamic var ownerLogin: String = ""
    @objc dynamic var storageType: String = StorageType.S3.rawValue
    @objc dynamic var prefix: String = ""
    @objc dynamic var parentFolderPrefix: String = ""
    
    @objc dynamic var size: String = ""
    @objc dynamic var localPathUUID: String = ""
    dynamic var related: List<RealmLocalFileForUpload> = List()
    
    public required convenience init(model: Model) {
        self.init()
        self.RealmID = model.VCSID
        
        self.ownerLogin = model.ownerLogin
        self.storageType = model.storageType.rawValue
        self.prefix = model.prefix
        
        self.size = model.size
        self.localPathUUID = model.localPathUUID
        
        let relatedArray = model.related
        let realmRelatedArray = List<RealmLocalFileForUpload>()
        relatedArray.forEach {
            realmRelatedArray.append(RealmLocalFileForUpload(model: $0))
        }
        self.related = realmRelatedArray
        
        let parentPrefix = self.prefix.deletingLastPathComponent.VCSNormalizedURLString()
        self.parentFolderPrefix = parentPrefix
    }
    
    
    public var entity: LocalFileForUpload {
        let relatedArray = self.related.compactMap({ $0.entity })
        let arrRelated = Array(relatedArray)
        
        return LocalFileForUpload(ownerLogin: self.ownerLogin,
                                  storageType: StorageType.typeFromString(type: self.storageType),
                                  prefix: self.prefix,
                                  size: self.size,
                                  related: arrRelated,
                                  localPathUUID: self.localPathUUID)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        
        result["ownerLogin"] = self.ownerLogin
        result["storageType"] = self.storageType
        result["prefix"] = self.prefix
        
        result["size"] = self.size
        result["localPathUUID"] = self.localPathUUID
        
        let partialRelated = Array(self.related.compactMap({ $0.partialUpdateModel }))
        result["related"] = partialRelated
        
        return result
    }
}
