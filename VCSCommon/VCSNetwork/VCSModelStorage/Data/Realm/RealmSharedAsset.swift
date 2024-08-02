//import Foundation
//import Realm
//import RealmSwift
//
//public class RealmSharedAsset: Object, RealmAssetWrapperWithSorting, VCSRealmObject {
//    public typealias Model = VCSSharedAssetWrapper
//    
//    @Persisted(primaryKey: true) public var RealmID: String = "nil"
//    @Persisted var asset: RealmSharedFileFolderAssetWrapper?
//    @Persisted var assetType: String = AssetType.file.rawValue
//    @Persisted var resourceURI: String = ""
//    
//    public var fakeRealmID: String { return asset?.fileAsset?.RealmID ?? asset?.folderAsset?.RealmID ?? self.RealmID }
//    public var fakeSortingName: String { return asset?.fileAsset?.name ?? asset?.folderAsset?.name ?? "" }
//    public var fakeSortingDate: Date { return self.asset?.fileAsset?.entity.sortingDate ?? Date() }
//    public var fakeSortingSize: String { return asset?.fileAsset?.size ?? "0"}
//    public var fakeFilterShowingOffline: Bool { return self.isAvailableOnDevice }
//    private var isAvailableOnDevice: Bool { return self.asset?.isAvailableOnDevice ?? false }
//    
//    required convenience public init(model: Model) {
//        self.init()
//        
//        self.RealmID = model.resourceURI
//        self.asset = RealmSharedFileFolderAssetWrapper(model: model.asset)
//        self.assetType = model.assetType.rawValue
//        self.resourceURI = model.resourceURI
//    }
//    
//    public var entity: Model {
//        return VCSSharedAssetWrapper(asset: self.asset!.entity, assetType: AssetType.init(rawValue: self.assetType), resourceURI: self.resourceURI)
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
//        
//        return result
//    }
//}
