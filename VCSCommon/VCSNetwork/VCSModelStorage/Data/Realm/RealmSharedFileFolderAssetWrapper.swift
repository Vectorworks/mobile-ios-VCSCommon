//import Foundation
//import Realm
//import RealmSwift
//
//public class RealmSharedFileFolderAssetWrapper: Object, VCSRealmObject {
//    public typealias Model = Asset
//    
//    @Persisted(primaryKey: true) public var RealmID: String = "nil"
//    @Persisted var fileAsset: RealmFile?
//    @Persisted var folderAsset: RealmFolder?
//    
//    func assetObjectPrimaryKey() -> String {
//        var result: String = "nil"
//        if let fileAsset = self.fileAsset {
//            result = fileAsset.RealmID
//        }
//        if let folderAsset = self.folderAsset {
//            result = folderAsset.RealmID
//        }
//        return result
//    }
//    
//    public var isAvailableOnDevice: Bool {
//        var result: Bool = false
//        if let fileAsset = self.fileAsset {
//            result = fileAsset.isAvailableOnDevice
//        }
//        if let folderAsset = self.folderAsset {
//            result = folderAsset.isAvailableOnDevice
//        }
//        return result
//    }
//    
//    required convenience public init(model: Model) {
//        self.init()
//        
//        if (model.isFolder) {
//            if let folder = model as? VCSFolderResponse {
//                self.folderAsset = RealmFolder(model: folder)
//                self.RealmID = self.folderAsset!.RealmID
//            }
//        } else {
//            if let file = model as? VCSFileResponse {
//                self.fileAsset = RealmFile(model: file)
//                self.RealmID = self.fileAsset!.RealmID
//            }
//        }
//    }
//    
//    public var entity: Model {
//        if self.fileAsset != nil {
//            return self.fileAsset!.entity
//        }
//        if self.folderAsset != nil {
//            return self.folderAsset!.entity
//        }
//        
//        return RealmFile().entity
//    }
//    
//    public var partialUpdateModel: [String : Any] {
//        var result: [String : Any] = [:]
//        
//        if let fileAsset = self.fileAsset {
//            result["fileAsset"] = fileAsset.partialUpdateModel
//            result["RealmID"] = fileAsset.RealmID
//        }
//        if let folderAsset = self.folderAsset {
//            result["folderAsset"] = folderAsset.partialUpdateModel
//            result["RealmID"] = folderAsset.RealmID
//        }
//        
//        return result
//    }
//}
