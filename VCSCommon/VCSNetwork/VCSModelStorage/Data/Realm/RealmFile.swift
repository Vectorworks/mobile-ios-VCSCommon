import Foundation
import RealmSwift

public class RealmFile: Object, VCSRealmObject {
    public typealias Model = VCSFileResponse
    
    @Persisted(primaryKey: true) public var RealmID: String = "nil"
    @Persisted var resourceURI: String = ""
    @Persisted var resourceID: String = ""
    @Persisted var exists: Bool = false
    @Persisted var isNameValid: Bool = false
    @Persisted var name: String = ""
    @Persisted var sharingInfo: RealmSharingInfo?
    @Persisted var prefix: String = ""
    @Persisted var storageType: String = StorageType.S3.rawValue
    @Persisted var flags: RealmFlags?
    @Persisted var ownerInfo: RealmOwnerInfo?
    @Persisted var versionID: String = ""
    @Persisted var thumbnail: String = ""
    @Persisted var size: String = ""
    public var sizeString: String { (Int(self.size) ?? 0).VCSSizeString }
    @Persisted var downloadURL: String = ""
    @Persisted var lastModified: String = ""
    @Persisted var thumbnail3D: String?
    @Persisted var previousVersions: List<RealmFile> = List()
    @Persisted var fileType: String?
    @Persisted var localFile: RealmLocalFile?
    @Persisted var localFilesAppFile: RealmLocalFilesAppFile?
    @Persisted var related: List<RealmFile> = List()
    @Persisted var ownerLogin: String = ""
    
    public var isAvailableOnDevice: Bool { return (self.isOnDisk) }
    
    private var isOnDisk: Bool {
        if self.filesForDownload.count == 0 {
            return false
        }
        
        let result: Bool = self.filesForDownload.reduce(true) { (res, fileInProject) -> Bool in
            return res && (fileInProject.localFile?.exists ?? false)
        }
        
        return result
    }
    
    public var filesForDownload: [RealmFile] {
        let relatedAndSelf = self.related + [self]
        return relatedAndSelf.filter { (file) -> Bool in
            //filter thumbnails
            if let thumbnailName = self.thumbnailURL?.lastPathComponent, file.name == thumbnailName {
                return false
            }
            return VCSFileResponse.relatedExtensions[self.name.pathExtension.uppercased()]?.contains { $0.isInFileName(name: file.name) } ?? true
        }
    }
    
    public var thumbnailURL: URL? {
        let stringURL = (self.thumbnail3D?.isEmpty ?? true) ? self.thumbnail : self.thumbnail3D!
        return URL(string: stringURL)
    }
    
    public required convenience init(model: Model) {
        self.init()
        
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
    
    public var entityFlat: VCSFileResponse {
        return VCSFileResponse(versionID: self.versionID,
                    thumbnail: self.thumbnail,
                    size: self.size,
                    downloadURL: self.downloadURL,
                    lastModified: self.lastModified,
                    thumbnail3D: self.thumbnail3D,
                    previousVersions: [],
                    fileType: self.fileType,
                    related: [],
                    
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
    
    public var entity: VCSFileResponse {
        let previousArray = self.previousVersions.compactMap({ $0.entity })
        let arrPrevious = Array(previousArray)
        
        let relatedArray = self.related.compactMap({ $0.entityFlat })
        let arrRelated = Array(relatedArray)
        
        return VCSFileResponse(versionID: self.versionID,
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
