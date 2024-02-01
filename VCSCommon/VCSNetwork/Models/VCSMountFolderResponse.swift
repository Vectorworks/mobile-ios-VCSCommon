import Foundation

public class VCSMountFolderResponse: NSObject, Codable {
    public var realmID: String = VCSUUID().systemUUID.uuidString
    
    public let isMounted: Bool
    public let mountPoint: VCSMountPointResponse?
    
    enum CodingKeys: String, CodingKey {
        case isMounted = "is_mounted"
        case mountPoint = "mount_point"
    }
}
