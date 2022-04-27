import Foundation
import RealmSwift

public class VCSRealmStorage: Object, VCSRealmObject {
    public typealias Model = VCSStorageResponse
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var name: String = ""
    @objc dynamic var fileURI: String = ""
    @objc dynamic var folderURI: String = ""
    @objc dynamic var resourceURI: String = ""
    @objc dynamic var storageType: String = ""
    @objc dynamic var autoprocessParent: String?
    @objc dynamic var accessType: String?
    @objc dynamic var pagesURL: String?
    dynamic var pages: List<VCSRealmStoragPages> = List()
    
    public required convenience init(model: VCSStorageResponse) {
        self.init()
        self.RealmID = model.folderURI
        self.name = model.name
        self.fileURI  = model.fileURI
        self.folderURI = model.folderURI
        self.storageType = model.storageType.rawValue
        self.autoprocessParent = model.autoprocessParent
        self.accessType = model.accessType
        self.pagesURL = model.pagesURL
        
        let pagesArray = model.pages
        let realmPagesArray = List<VCSRealmStoragPages>()
        pagesArray.forEach {
            realmPagesArray.append(VCSRealmStoragPages(model: $0))
        }
        self.pages = realmPagesArray
    }
    
    public var entity: VCSStorageResponse {
        let pagesArray = self.pages.compactMap({ $0.entity })
        let arrPages = Array(pagesArray)
        return VCSStorageResponse(name: self.name, folderURI: self.folderURI, fileURI: self.fileURI, storageType: StorageType(rawValue: self.storageType) ?? .INTERNAL, resourceURI: self.resourceURI, autoprocessParent: self.autoprocessParent, accessType: self.accessType, pagesURL: self.pagesURL, pages: arrPages)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["name"] = self.name
        result["fileURI"] = self.fileURI
        result["folderURI"] = self.folderURI
        result["storageType"] = self.storageType
        
        if let autoprocessParent = self.autoprocessParent {
            result["autoprocessParent"] = autoprocessParent
        }
        
        if let accessType = self.accessType {
            result["accessType"] = accessType
        }
        
        if let pagesURL = self.pagesURL {
            result["pagesURL"] = pagesURL
        }
        
        let partialPages = Array(self.pages.compactMap({ $0.partialUpdateModel }))
        if partialPages.count > 0 {
            result["pages"] = partialPages
        }
        
        return result
    }
}
