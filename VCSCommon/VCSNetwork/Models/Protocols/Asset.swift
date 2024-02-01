import Foundation

public protocol Asset: VCSCachable {
    var resourceURI: String { get }
    var resourceID: String { get }
    var exists: Bool { get }
    var isNameValid: Bool { get }
    var name: String { get }
    var sharingInfo: VCSSharingInfoResponse? { get }
    var flags: VCSFlagsResponse? { get }
    var ownerInfo: VCSOwnerInfoResponse? { get }
    
    var prefix: String  { get set }
    var storageType: StorageType { get }
    var storageTypeString: String { get }
    var storageTypeDisplayString: String { get }
    var isFolder: Bool { get }
    var isFile: Bool { get }
    var ownerLogin: String { get }
    
    var isAvailableOnDevice: Bool { get }
    var rID: String { get }
    var VCSID: String { get }
    func updateSharingInfo(other: VCSSharingInfoResponse)
    func updateSharedOwnerLogin(_ login: String)
    func loadLocalFiles()
    
    var realStorage: String { get }
    var realPrefix: String { get }
}
