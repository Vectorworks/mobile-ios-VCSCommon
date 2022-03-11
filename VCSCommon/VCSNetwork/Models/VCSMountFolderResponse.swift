import Foundation

@objc public class VCSMountFolderResponse: NSObject, Codable {
    public var realmID: String = UUID().uuidString
    
    public let isMounted: Bool
    public let mountPoint: VCSMountPointResponse?
    
    enum CodingKeys: String, CodingKey {
        case isMounted = "is_mounted"
        case mountPoint = "mount_point"
    }
}
