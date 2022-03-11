import Foundation
import RealmSwift

public class RealmFile: Object, VCSRealmObject {
    public typealias Model = VCSFileResponse
    override public class func primaryKey() -> String { return "RealmID" }
    
    @objc dynamic public var RealmID: String = "nil"
    @objc dynamic var resourceURI: String = ""
    @objc dynamic var resourceID: String = ""
    @objc dynamic var exists: Bool = false
    @objc dynamic var isNameValid: Bool = false
    @objc dynamic var name: String = ""
    @objc dynamic var sharingInfo: RealmSharingInfo?
    @objc dynamic var prefix: String = ""
    @objc dynamic var storageType: String = StorageType.S3.rawValue
    @objc dynamic var flags: RealmFlags?
    @objc dynamic var ownerInfo: RealmOwnerInfo?
    @objc dynamic var id: Int = 0
    @objc dynamic var versionID: String = ""
    @objc dynamic var thumbnail: String = ""
    @objc dynamic var size: String = ""
    @objc dynamic var downloadURL: String = ""
    @objc dynamic var lastModified: String = ""
    @objc dynamic var thumbnail3D: String?
    dynamic var previousVersions: List<RealmFile> = List()
    @objc dynamic var fileType: String?
    @objc dynamic var localFile: RealmLocalFile?
    @objc dynamic var localFilesAppFile: RealmLocalFilesAppFile?
    dynamic var related: List<RealmFile> = List()
    @objc dynamic var ownerLogin: String = ""
    
    
    public required convenience init(model: Model) {
        self.init()
        
        self.id = model.id
        self.RealmID = model.VCSID
        
        self.resourceURI = model.resourceURI
        self.resourceID = model.resourceID
        self.exists = model.exists
        self.isNameValid = model.isNameValid
        self.name = model.name
        if let sharingInfo = model.sharingInfo {
            sharingInfo.setNewRealmID(self.RealmID)
            self.sharingInfo = RealmSharingInfo(model: sharingInfo)
        }
        self.prefix = model.prefix
        self.storageType = model.storageType.rawValue
        if let flags = model.flags {
            flags.realmID = self.RealmID
            self.flags = RealmFlags(model: flags)
        }
        if let ownerInfo = model.ownerInfo {
            ownerInfo.realmID = self.RealmID
            self.ownerInfo = RealmOwnerInfo(model: ownerInfo)
        }
        
        self.versionID = model.versionID
        self.thumbnail = model.thumbnail
        self.size = model.size
        self.downloadURL = model.downloadURL
        self.lastModified = model.lastModified
        self.thumbnail3D = model.thumbnail3D
        self.fileType = model.fileType
        
        if let localFile = model.localFile {
            self.localFile = RealmLocalFile(model: localFile)
        }
        
        if let localFilesAppFile = model.localFilesAppFile {
            self.localFilesAppFile = RealmLocalFilesAppFile(model: localFilesAppFile)
        }
        
        self.ownerLogin = model.ownerLogin
        
        let previousArray = model.previousVersions
        let realmPreviousArrayArray = List<RealmFile>()
        previousArray.forEach {
            realmPreviousArrayArray.append(RealmFile(model: $0))
        }
        self.previousVersions = realmPreviousArrayArray
        
        
        let relatedArray = model.related
        let realmRelatedArray = List<RealmFile>()
        relatedArray.forEach {
            realmRelatedArray.append(RealmFile(model: $0))
        }
        self.related = realmRelatedArray
    }
    
    public var entity: VCSFileResponse {
        let previousArray = self.previousVersions.compactMap({ $0.entity })
        let arrPrevious = Array(previousArray)
        
        let relatedArray = self.related.compactMap({ $0.entity })
        let arrRelated = Array(relatedArray)
        
        return VCSFileResponse(id: self.id,
                    versionID: self.versionID,
                    thumbnail: self.thumbnail,
                    size: self.size,
                    downloadURL: self.downloadURL,
                    lastModified: self.lastModified,
                    thumbnail3D: self.thumbnail3D,
                    previousVersions: arrPrevious,
                    fileType: self.fileType,
                    related: arrRelated,
                    
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
                    localFile: self.localFile?.entity,
                    localFilesAppFile: self.localFilesAppFile?.entity,
                    ownerLogin: self.ownerLogin,
                    VCSID: self.RealmID)
    }
    
    public var partialUpdateModel: [String : Any] {
        var result: [String : Any] = [:]
        
        result["RealmID"] = self.RealmID
        result["id"] = self.id
        result["versionID"] = self.versionID
        result["thumbnail"] = self.thumbnail
        result["size"] = self.size
        result["downloadURL"] = self.downloadURL
        result["lastModified"] = self.lastModified
        result["resourceURI"] = self.resourceURI
        result["resourceID"] = self.resourceID
        result["exists"] = self.exists
        result["isNameValid"] = self.isNameValid
        result["name"] = self.name
        result["prefix"] = self.prefix
        result["storageType"] = self.storageType
        result["ownerLogin"] = self.ownerLogin
        
        let partialPreviousVersions = Array(self.previousVersions.compactMap({ $0.partialUpdateModel }))
        if partialPreviousVersions.count > 0 {
            result["previousVersions"] = partialPreviousVersions
        }
        
        let partialRelated = Array(self.related.compactMap({ $0.partialUpdateModel }))
        if partialRelated.count > 0 {
            result["related"] = partialRelated
        }
        
        if let localFile = self.localFile {
            result["localFile"] = localFile.partialUpdateModel
        }
        
        if let localFilesAppFile = self.localFilesAppFile {
            result["localFilesAppFile"] = localFilesAppFile.partialUpdateModel
        }
        
        if let thumbnail3D = self.thumbnail3D {
            result["thumbnail3D"] = thumbnail3D
        }
        
        if let fileType = self.fileType {
            result["fileType"] = fileType
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
