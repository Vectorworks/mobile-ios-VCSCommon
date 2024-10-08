import Foundation
import RealmSwift
import CocoaLumberjackSwift

public class UploadJobLocalFile: Identifiable {
    public enum UploadingState: String {
        case Ready
        case Waiting
        case Uploading
        case Done
        case Error
    }
    
    public var VCSID: String
    
    public var ownerLogin: String
    public let storageType: StorageType
    public var prefix: String
    public var size: String { return self.uploadPathURL.fileSizeString }
    public var sizeAsInt: Int { return Int(self.uploadPathURL.fileSizeString) ?? 0 }
    public let uploadPathSuffix: String
    public var uploadPathURL: URL { return FileManager.AppUploadsDirectory.appendingPathComponent(self.uploadPathSuffix) }
    
    public var related: [UploadJobLocalFile]
    public var parentPatchFile: VCSFileResponse?
    
    public var uploadingState: UploadingState = .Ready
    
    public var parentUploadJob: UploadJob? {
        return UploadJob.uploadJobs.first { $0.localFiles.contains(where: { (localFile: UploadJobLocalFile) in localFile.VCSID == self.VCSID }) }
    }

        
    public init?(ownerLogin: String, storageType: StorageType, prefix: String, tempFileURL: URL, copyFile: Bool = false, related: [UploadJobLocalFile], parentPatchFile: VCSFileResponse? = nil) {
        let UUIDString = VCSUUID().systemUUID.uuidString
        self.VCSID = UUIDString
        
        self.ownerLogin = ownerLogin
        self.storageType = storageType
        self.prefix = prefix
        self.uploadPathSuffix = UUIDString
        self.related = related
        self.parentPatchFile = parentPatchFile
        
        //move files to uploads temp folder and save only the suffix
        if self.uploadPathURL.exists == false {
            do {
                if copyFile {
                    try FileUtils.copyFile(at: tempFileURL, to: self.uploadPathURL)
                } else {
                    try FileManager.default.moveItem(at: tempFileURL, to: self.uploadPathURL)
                }
            } catch { 
                DDLogError("UploadJobLocalFile init(ownerLogin: " + error.localizedDescription)
                return nil
            }
            
        }
    }
    
    public init(file: VCSFileResponse) {
        let UUIDString = file.rID
        self.VCSID = UUIDString
        
        self.ownerLogin = file.ownerLogin
        self.storageType = file.storageType
        self.prefix = file.prefix
        self.uploadPathSuffix = VCSUUID().systemUUID.uuidString
        self.related = file.related.map({ UploadJobLocalFile(file: $0) })
        self.parentPatchFile = nil
    }
    
    //Realm only
    internal init(fileID: String, ownerLogin: String, storageType: StorageType, prefix: String, related: [UploadJobLocalFile], uploadPathSuffix: String, uploadingState: UploadingState) {
        self.VCSID = fileID
        
        self.ownerLogin = ownerLogin
        self.storageType = storageType
        self.prefix = prefix
        self.uploadPathSuffix = uploadPathSuffix
        self.uploadingState = uploadingState
        self.related = related
    }
    
    final public class func ==(lhs: UploadJobLocalFile, rhs: UploadJobLocalFile) -> Bool {
        return lhs.VCSID == rhs.VCSID
    }
    
    public static func resetStateOnStartUp() {
        let uploadingLocalFiles = VCSRealmDB.realm.objects(RealmUploadJobLocalFile.self).where({
            $0.uploadingState == UploadingState.Waiting.rawValue
            || $0.uploadingState == UploadingState.Uploading.rawValue
            || $0.uploadingState == UploadingState.Error.rawValue
        })
        try? VCSRealmDB.realm.write {
            uploadingLocalFiles.forEach {
                $0.uploadingState = UploadingState.Ready.rawValue
            }
        }
    }
    
    public var isNameValid: Bool {
        return self.flags?.isNameValid ?? false
    }
    
    //always show local files for upload on top when sorting by date
    public lazy var sortingDate: Date = { return Date() }()
}

extension UploadJobLocalFile: FileCellPresentable {
    public var rID: String { return self.VCSID }
    public var name: String { return self.prefix.lastPathComponent }
    public var hasWarning: Bool { return self.flags?.hasWarning ?? true }
    public var isShared: Bool { return false }
    public var hasLink: Bool { return false }
    public var sharingInfoData: VCSSharingInfoResponse? { return nil }
    public var isAvailableOnDevice: Bool { return true }
    public var filterShowingOffline: Bool { return self.isAvailableOnDevice }
    public var lastModifiedString: String { return "Local file".vcsLocalized }
    public var sizeString: String { return self.size }
    public var thumbnailURL: URL? {
        var result: URL?
        if let relatedPNG = self.related.first(where: {  VCSFileType.PNG.isInFileName(name: $0.name) }) {
            result = relatedPNG.uploadPathURL
        }
        return result
    }
    public var permissions: [String] { return [] }
    public func hasPermission(_ permission: String) -> Bool { self.permissions.contains(permission) }
}

extension UploadJobLocalFile: VCSCellDataHolder {
    public var cellData: VCSCellPresentable {
        return self
    }
    public var cellFileData: FileCellPresentable? {
        return self
    }
    public var assetData: Asset? {
        return self
    }
}

extension UploadJobLocalFile: FileAsset {
    public var downloadURLString: String { return "" }
    public var localPathString: String? { return self.uploadPathURL.path }
    public var relatedFileAssets: [FileAsset] { return self.related }
    public var fileTypeString: String? { return VCSFileType(rawValue: self.name.pathExtension)?.rawValue }
    public var resourceURI: String { return "" }
    public var resourceID: String { return self.VCSID }
    public var exists: Bool { return true }
    public var sharingInfo: VCSSharingInfoResponse? { return nil }
    public var flags: VCSFlagsResponse? { return VCSFlagsResponse(isNameValid: true, isFileTypeSupported: true, isNameDuplicate: false, isSupported: true, isMounted:  false, isMountPoint: false, realmID: self.VCSID) }
    public var ownerInfo: VCSOwnerInfoResponse? { return nil }
    public var storageTypeString: String { return self.storageType.rawValue }
    public var storageTypeDisplayString: String { self.storageType.displayName }
    public var isFolder: Bool { return !self.isFile }
    public var isFile: Bool { return true }
    
    public func updateSharingInfo(other: VCSSharingInfoResponse) {}
    public func updateSharedOwnerLogin(_ login: String) {}
    public func loadLocalFiles() {}
    
    public var realStorage: String { return self.storageType.rawValue }
    public var realPrefix: String { return self.prefix.VCSNormalizedURLString() }
}

extension UploadJobLocalFile: VCSCachable {
    public typealias RealmModel = RealmUploadJobLocalFile
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()

    public func addToCache() {
        UploadJobLocalFile.realmStorage.addOrUpdate(item: self)
    }

    public func addOrPartialUpdateToCache() {
        if UploadJobLocalFile.realmStorage.getByIdOfItem(item: self) != nil {
            UploadJobLocalFile.realmStorage.partialUpdate(item: self)
        } else {
            UploadJobLocalFile.realmStorage.addOrUpdate(item: self)
        }
    }

    public func partialUpdateToCache() {
        UploadJobLocalFile.realmStorage.partialUpdate(item: self)
    }
    
    public func deleteFromCache() {
        self.related.forEach { $0.deleteFromCache() }
        AssetUploader.removeUploadedFileFromAPIClient(self)
        UploadJobLocalFile.realmStorage.delete(item: self)
    }
}
