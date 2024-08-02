import Foundation
import SwiftData

@Model
public final class VCSFlagsResponse: Codable {
    public var realmID: String = VCSUUID().systemUUID.uuidString
    public let isNameValid: Bool
    public let isFileTypeSupported: Bool
    public let isNameDuplicate: Bool
    public let isSupported: Bool
    public let isMounted: Bool
    public let isMountPoint: Bool
    
    
    public var hasWarning:Bool { return !self.isNameValid || !self.isFileTypeSupported || self.isNameDuplicate }
    
    
    
    public init(isNameValid: Bool, isFileTypeSupported: Bool, isNameDuplicate: Bool, isSupported: Bool, isMounted: Bool, isMountPoint: Bool, realmID: String) {
        self.realmID = realmID
        self.isNameValid = isNameValid
        self.isFileTypeSupported = isFileTypeSupported
        self.isNameDuplicate = isNameDuplicate
        self.isSupported = isSupported
        self.isMounted = isMounted
        self.isMountPoint = isMountPoint
    }
    
    //Codable
    enum CodingKeys: String, CodingKey {
        case isNameValid = "is_name_valid"
        case isFileTypeSupported = "is_file_type_supported"
        case isNameDuplicate = "is_name_duplicate"
        case isSupported = "is_supported"
        case isMounted = "is_mounted"
        case isMountPoint = "is_mount_point"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        isNameValid = try container.decode(Bool.self, forKey: .isNameValid)
        isFileTypeSupported = try container.decode(Bool.self, forKey: .isFileTypeSupported)
        isNameDuplicate = try container.decode(Bool.self, forKey: .isNameDuplicate)
        isSupported = try container.decode(Bool.self, forKey: .isSupported)
        isMounted = try container.decode(Bool.self, forKey: .isMounted)
        isMountPoint = try container.decode(Bool.self, forKey: .isMountPoint)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(isNameValid, forKey: .isNameValid)
        try container.encode(isFileTypeSupported, forKey: .isFileTypeSupported)
        try container.encode(isNameDuplicate, forKey: .isNameDuplicate)
        try container.encode(isSupported, forKey: .isSupported)
        try container.encode(isMounted, forKey: .isMounted)
        try container.encode(isMountPoint, forKey: .isMountPoint)
    }
}

extension VCSFlagsResponse: VCSCacheable {
    public var rID: String { return realmID }
}
