import Foundation
import RealmSwift

public class RealmSharedLink: Object, VCSRealmObject {
    public typealias Model = SharedLink
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var isSampleFiles:Bool = false
    @objc dynamic var link: String = ""
    @objc dynamic var linkName:String?
    @objc dynamic var linkThumbnailURL:String?
    @objc dynamic var dateCreated: Date = Date()
    @objc dynamic var sharedAsset: RealmShareableLinkResponse?
    @objc dynamic var owner: RealmVCSUser?
    
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
