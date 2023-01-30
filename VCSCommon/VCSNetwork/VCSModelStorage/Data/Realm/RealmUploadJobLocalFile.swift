import Foundation
import RealmSwift

public class RealmUploadJobLocalFile: Object, VCSRealmObject {
    public typealias Model = UploadJobLocalFile
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    
    @objc dynamic var ownerLogin: String = ""
    @objc dynamic var storageType: String = ""
    @objc dynamic public var prefix: String = ""
    @objc dynamic var uploadPathSuffix: String = ""
    @objc dynamic public var uploadingState: String = ""
    dynamic var related: List<RealmUploadJobLocalFile> = List()
    
    //for filtering
    @objc dynamic var parentFolderPrefix: String = ""
    
    public required convenience init(model: Model) {
        self.init()
        self.RealmID = model.VCSID
        
        self.ownerLogin = model.ownerLogin
        self.storageType = model.storageType.rawValue
        self.prefix = model.prefix
        self.uploadPathSuffix = model.uploadPathSuffix
        
        self.uploadingState = model.uploadingState.rawValue
        
        let relatedArray = model.related
        let realmRelatedArray = List<RealmUploadJobLocalFile>()
        relatedArray.forEach {
            realmRelatedArray.append(RealmUploadJobLocalFile(model: $0))
        }
        self.related = realmRelatedArray
        
        let parentPrefix = self.prefix.deletingLastPathComponent.VCSNormalizedURLString()
        self.parentFolderPrefix = parentPrefix

    }
    
    
    public var entity: UploadJobLocalFile {
        let relatedArray = self.related.compactMap({ $0.entity })
        let arrRelated = Array(relatedArray)
        
        return UploadJobLocalFile(fileID: self.RealmID,
                                  ownerLogin: self.ownerLogin,
                                  storageType: StorageType.typeFromString(type: self.storageType),
                                  prefix: self.prefix,
                                  related: arrRelated,
                                  uploadPathSuffix: self.uploadPathSuffix,
                                  uploadingState: UploadJobLocalFile.UploadingState(rawValue: self.uploadingState) ?? UploadJobLocalFile.UploadingState.Ready)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        
        result["ownerLogin"] = self.ownerLogin
        result["storageType"] = self.storageType
        result["prefix"] = self.prefix
        result["uploadPathSuffix"] = self.uploadPathSuffix
        
        let partialRelated = Array(self.related.compactMap({ $0.partialUpdateModel }))
        result["related"] = partialRelated
        
        result["parentFolderPrefix"] = self.parentFolderPrefix
        result["uploadingState"] = self.uploadingState
        
        return result
    }
}
