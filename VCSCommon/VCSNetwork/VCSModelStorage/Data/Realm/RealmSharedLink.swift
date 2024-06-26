import Foundation
import RealmSwift

//Base class for RealmSharedLink and RealmSharedWithMeAsset
public protocol RealmAssetWrapperWithSorting {
    var fakeRealmID: String { get }
    var fakeSortingName: String { get }
    var fakeSortingDate: Date { get }
    var fakeSortingSize: String { get }
    var fakeFilterShowingOffline: Bool { get }
    
}
    

public class RealmSharedLink: Object, RealmAssetWrapperWithSorting, VCSRealmObject {
    public typealias Model = SharedLink
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted var isSampleFiles:Bool = false
    @Persisted var link: String = ""
    @Persisted var linkName:String?
    @Persisted var linkThumbnailURL:String?
    @Persisted var dateCreated: Date = Date()
    @Persisted var sharedAsset: RealmShareableLinkResponse?
    @Persisted var owner: RealmVCSUser?
    
    public var fakeRealmID: String { return RealmID }
    public var fakeSortingName: String { return sharedAsset?.asset?.fileAsset?.name ?? sharedAsset?.asset?.folderAsset?.name ?? linkName ?? link }
    public var fakeSortingDate: Date {
        var result = self.dateCreated
        if self.isSampleFiles {
            result = self.sharedAsset?.dateCreated.VCSDateFromISO8061 ?? self.dateCreated
        }
        return result
    }
    public var fakeSortingSize: String { return sharedAsset?.asset?.fileAsset?.size ?? "0" }
    
    private var isResolved: Bool { return self.sharedAsset != nil }
    private var isAvailableOnDevice: Bool { return self.sharedAsset?.asset?.isAvailableOnDevice ?? false }
    
    public var fakeFilterShowingOffline: Bool {
        return self.isResolved ? self.isAvailableOnDevice : true
    }
    
    public required convenience init(model: Model) {
        self.init()
        self.RealmID = model.rID
        self.isSampleFiles = model.isSampleFiles
        self.link = model.link
        self.linkName = model.linkName
        self.linkThumbnailURL = model.linkThumbnailURL?.absoluteString
        self.dateCreated = model.dateCreated
        if let sharedAsset = model.sharedAsset {
            self.sharedAsset = RealmShareableLinkResponse(model: sharedAsset)
        }
        
        if let owner = model.owner {
            self.owner = RealmVCSUser(model: owner)
        }
    }
    
    public var entity: SharedLink {
        return SharedLink(link: self.link, isSampleFiles: self.isSampleFiles, sharedAsset: self.sharedAsset?.entity, owner: self.owner?.entity, date: self.dateCreated, linkName: self.linkName, linkThumbnailURL: self.linkThumbnailURL)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["isSampleFiles"] = self.isSampleFiles
        result["link"] = self.link
        result["linkName"] = self.linkName
        result["linkThumbnailURL"] = self.linkThumbnailURL
        result["dateCreated"] = self.dateCreated
        if let sharedAsset = self.sharedAsset {
            result["sharedAsset"] = sharedAsset.partialUpdateModel
        }
        
        result["owner"] = self.owner?.partialUpdateModel
        
        return result
    }
}
