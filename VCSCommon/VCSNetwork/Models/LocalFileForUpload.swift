import Foundation

@objc public class LocalFileForUpload: NSObject {
    
    public var VCSID: String
    
    public let ownerLogin: String
    public let storageType: StorageType
    public var prefix: String
    
    public let size: String
    public let localPathUUID: String
    public var related: [LocalFileForUpload]
    
    
    public var localPath: String {  return FileManager.uploadPath(uuidString: self.localPathUUID, pathExtension: self.name.pathExtension).path }
    public var localPathURL: URL {  return URL(fileURLWithPath: self.localPath) }
    
    public init(ownerLogin: String, storageType: StorageType, prefix: String, size: String, related: [LocalFileForUpload], localPathUUID: String = UUID().uuidString) {
        self.ownerLogin = ownerLogin
        self.storageType = storageType
        self.prefix = prefix
        
        self.VCSID = localPathUUID
        
        self.size = size
        self.localPathUUID = localPathUUID
        self.related = related
        
        super.init()
    }
    
    final public class func ==(lhs: LocalFileForUpload, rhs: LocalFileForUpload) -> Bool {
        return lhs.VCSID == rhs.VCSID
    }
    
    public func removeFromCache() {
        self.related.forEach { LocalFileForUpload.realmStorage.delete(item: $0) }
        LocalFileForUpload.realmStorage.delete(item: self)
    }
    
    public var isNameValid: Bool {
        return self.flags?.isNameValid ?? false
    }
    
    //always show local files for upload on top when sorting by date
    public lazy var sortingDate: Date = { return Date() }()
}

extension LocalFileForUpload: FileCellPresentable {
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
            result = URL(fileURLWithPath: relatedPNG.localPath)
        }
        return result
    }
    public var permissions: [String] { return [] }
    public func hasPermission(_ permission: String) -> Bool { self.permissions.contains(permission) }
}

extension LocalFileForUpload: VCSCellDataHolder {
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

extension LocalFileForUpload: FileAsset {
    public var downloadURLString: String { return "" }
    public var localPathString: String? { return self.localPath }
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
    
    @objc public var realStorage: String { return self.storageType.rawValue }
    @objc public var realPrefix: String { return self.prefix.VCSNormalizedURLString() }
}

extension LocalFileForUpload: VCSCachable {
    public typealias RealmModel = RealmLocalFileForUpload
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        LocalFileForUpload.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if LocalFileForUpload.realmStorage.getByIdOfItem(item: self) != nil {
            LocalFileForUpload.realmStorage.partialUpdate(item: self)
        } else {
            LocalFileForUpload.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        LocalFileForUpload.realmStorage.partialUpdate(item: self)
    }
}
