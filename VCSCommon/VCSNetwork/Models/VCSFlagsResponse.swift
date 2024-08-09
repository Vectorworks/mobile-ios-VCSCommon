import Foundation

public class VCSFlagsResponse: Codable {
    public let isNameValid, isFileTypeSupported, isNameDuplicate, isSupported, isMounted, isMountPoint: Bool
    public var realmID: String = VCSUUID().systemUUID.uuidString
    
    public var hasWarning:Bool { return !self.isNameValid || !self.isFileTypeSupported || self.isNameDuplicate }
    
    enum CodingKeys: String, CodingKey {
        case isNameValid = "is_name_valid"
        case isFileTypeSupported = "is_file_type_supported"
        case isNameDuplicate = "is_name_duplicate"
        case isSupported = "is_supported"
        case isMounted = "is_mounted"
        case isMountPoint = "is_mount_point"
    }
    
    public init(isNameValid: Bool, isFileTypeSupported: Bool, isNameDuplicate: Bool, isSupported: Bool, isMounted: Bool, isMountPoint: Bool, realmID: String) {
        self.realmID = realmID
        self.isNameValid = isNameValid
        self.isFileTypeSupported = isFileTypeSupported
        self.isNameDuplicate = isNameDuplicate
        self.isSupported = isSupported
        self.isMounted = isMounted
        self.isMountPoint = isMountPoint
    }
}

extension VCSFlagsResponse: VCSCachable {
    public typealias RealmModel = RealmFlags
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSFlagsResponse.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSFlagsResponse.realmStorage.getByIdOfItem(item: self) != nil {
            VCSFlagsResponse.realmStorage.partialUpdate(item: self)
        } else {
            VCSFlagsResponse.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSFlagsResponse.realmStorage.partialUpdate(item: self)
    }
    
    public func deleteFromCache() {
        VCSFlagsResponse.realmStorage.delete(item: self)
    }
}
