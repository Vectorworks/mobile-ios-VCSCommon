import Foundation
import RealmSwift

public class RealmFolder: Object, VCSRealmObject {
    public typealias Model = VCSFolderResponse
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var resourceURI: String = ""
    @objc dynamic var resourceID: String = ""
    @objc dynamic var exists: Bool = false
    @objc dynamic var isNameValid: Bool = false
    @objc public dynamic var name: String = ""
    @objc dynamic var sharingInfo: RealmSharingInfo?
    @objc dynamic var prefix: String = ""
    @objc dynamic var storageType: String = StorageType.S3.rawValue
    @objc dynamic var flags: RealmFlags?
    @objc dynamic var ownerInfo: RealmOwnerInfo?
    @objc dynamic var parent: String?
    @objc dynamic var autoprocessParent: String?
    
    public var files: List<RealmFile> = List()
    public var subfolders: List<RealmFolder> = List()
    @objc dynamic var ownerLogin: String = ""
    
    public required convenience init(model: Model) {
        self.init()
        
        self.RealmID = model.VCSID
        self.prefix = model.prefix
        self.storageType = model.storageType.rawValue
        self.resourceURI = model.resourceURI
        self.resourceID = model.resourceID
        self.exists = model.exists
        self.isNameValid = model.isNameValid
        self.name = model.name
        if let sharingInfo = model.sharingInfo {
            sharingInfo.setNewRealmID(self.RealmID)
            self.sharingInfo = RealmSharingInfo(model:sharingInfo )
        }
        if let flags = model.flags {
            flags.realmID = self.RealmID
            self.flags = RealmFlags(model: flags)
        }
        if let ownerInfo = model.ownerInfo {
            ownerInfo.realmID = self.RealmID
            self.ownerInfo = RealmOwnerInfo(model: ownerInfo)
        }
        self.parent = model.parent
        self.autoprocessParent = model.autoprocessParent
        
        self.ownerLogin = model.ownerLogin

        let fileArray = model.files ?? []
        let realmFileArray = List<RealmFile>()
        fileArray.forEach {
            realmFileArray.append(RealmFile(model: $0))
        }
        self.files = realmFileArray
        
        let folderArray = model.subfolders ?? []
        let realmFolderArray = List<RealmFolder>()
        folderArray.forEach {
            realmFolderArray.append(RealmFolder(model: $0))
        }
        self.subfolders = realmFolderArray
    }
    
    public var entity: VCSFolderResponse {
        let filesArray = self.files.compactMap({ $0.entity })
        let arrFiles = Array(filesArray)
        
        let folderArray = self.subfolders.compactMap({ $0.entity })
        let arrFolder = Array(folderArray)
        
        return VCSFolderResponse(files: arrFiles,
                      parent: self.parent,
                      subfolders: arrFolder,
                      autoprocessParent: self.autoprocessParent,
                      resourceURI: self.resourceURI,
                      resourceID: self.resourceID,
                      exists: self.exists,
                      isNameValid: self.isNameValid,
                      name: self.name,
                      sharingInfo: self.sharingInfo?.entity,
                      prefix: self.prefix,
                      storageType: StorageType.typeFromString(type: self.storageType),
                      flags: self.flags?.entity,
                      ownerInfo: self.ownerInfo?.entity,
                      ownerLogin: self.ownerLogin,
                      VCSID: self.RealmID)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["resourceURI"] = self.resourceURI
        result["resourceID"] = self.resourceID
        result["exists"] = self.exists
        result["isNameValid"] = self.isNameValid
        result["name"] = self.name
        result["prefix"] = self.prefix
        result["storageType"] = self.storageType
        
        result["ownerLogin"] = self.ownerLogin
        
        let partialFiles = Array(self.files.compactMap({ $0.partialUpdateModel }))
        if self.RealmID == VCSFolderResponse.addToCacheRootFolderID {
            result["files"] = partialFiles
        } else if partialFiles.count > 0 {
            result["files"] = partialFiles
        }
        
        let partialSubfolders = Array(self.subfolders.compactMap({ $0.partialUpdateModel }))
        if self.RealmID == VCSFolderResponse.addToCacheRootFolderID {
            result["subfolders"] = partialSubfolders
        } else if partialSubfolders.count > 0 {
            result["subfolders"] = partialSubfolders
        }
        
        if let parent = self.parent {
            result["parent"] = parent
        }
        
        if let autoprocessParent = self.autoprocessParent {
            result["autoprocessParent"] = autoprocessParent
        }
        
        if let sharingInfo = self.sharingInfo {
            result["sharingInfo"] = sharingInfo.partialUpdateModel
        }
        
        if let flags = self.flags {
            result["flags"] = flags.partialUpdateModel
        }
        
        if let ownerInfo = self.ownerInfo {
            result["ownerInfo"] = ownerInfo.partialUpdateModel
        }
        
        return result
    }
}
