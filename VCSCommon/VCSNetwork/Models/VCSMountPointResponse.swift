import Foundation
import SwiftData

@Model
public final class VCSMountPointResponse: Codable {
    public var modelID: String = VCSUUID().systemUUID.uuidString
    
    public let storageType: StorageType
    public let prefix: String
    public let path: String
    public let mountPath: String
    
    public init(storageType: StorageType, prefix: String, path: String, mountPath: String, modelID: String) {
        self.modelID = modelID
        self.storageType = storageType
        self.prefix = prefix
        self.path = path
        self.mountPath = mountPath
    }
    
    //MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case modelID
        case storageType = "storage_type"
        case prefix = "prefix"
        case path = "path"
        case mountPath = "mount_path"
        case _$backingData
        case _$observationRegistrar
    }
    
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        storageType = try container.decode(StorageType.self, forKey: .storageType)
        prefix = try container.decode(String.self, forKey: .prefix)
        path = try container.decode(String.self, forKey: .path)
        mountPath = try container.decode(String.self, forKey: .mountPath)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(storageType, forKey: .storageType)
        try container.encode(prefix, forKey: .prefix)
        try container.encode(path, forKey: .path)
        try container.encode(mountPath, forKey: .mountPath)
    }
}

extension VCSMountPointResponse: VCSCacheable {
    public var rID: String { return modelID }
}
