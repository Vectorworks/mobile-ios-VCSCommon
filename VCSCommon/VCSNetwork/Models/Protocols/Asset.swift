import Foundation

@objc public protocol Asset: VCSCachable {
    @objc var resourceURI: String { get }
    @objc var resourceID: String { get }
    var exists: Bool { get }
    var isNameValid: Bool { get }
    var name: String { get }
    var sharingInfo: VCSSharingInfoResponse? { get }
    var flags: VCSFlagsResponse? { get }
    var ownerInfo: VCSOwnerInfoResponse? { get }
    
    @objc var prefix: String  { get set }
    @objc var storageTypeString: String { get }
    var storageTypeDisplayString: String { get }
    var isFolder: Bool { get }
    var isFile: Bool { get }
    @objc var ownerLogin: String { get }
    
    var isAvailableOnDevice: Bool { get }
    var rID: String { get }
    var VCSID: String { get }
    func updateSharingInfo(other: VCSSharingInfoResponse)
    func updateSharedOwnerLogin(_ login: String)
    func loadLocalFiles()
    
    @objc var realStorage: String { get }
    @objc var realPrefix: String { get }
}
