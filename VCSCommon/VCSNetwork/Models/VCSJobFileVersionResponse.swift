import Foundation
import SwiftData

@Model
public final class VCSJobFileVersionResponse: Codable {
    //TODO: test changes
    public let owner: String
    public let container: String
    public let provider: String
    public let fileType: String
    public let path: String
    public let id: Int
    public let versionID: String
    public let resourceID: String
    public let VCSID: String
    
    enum CodingKeys: String, CodingKey {
        case owner, container, provider
        case fileType = "file_type"
        case path
        case id
        case versionID = "version_id"
        case resourceID = "resource_id"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.owner = try container.decode(String.self, forKey: CodingKeys.owner)
        self.container = try container.decode(String.self, forKey: CodingKeys.container)
        self.provider = try container.decode(String.self, forKey: CodingKeys.provider)
        self.fileType = try container.decode(String.self, forKey: CodingKeys.fileType)
        self.path = try container.decode(String.self, forKey: CodingKeys.path)
        self.id = try container.decode(Int.self, forKey: CodingKeys.id)
        self.versionID = try container.decode(String.self, forKey: CodingKeys.versionID)
        let resourceID = try container.decode(String.self, forKey: CodingKeys.resourceID)
        self.resourceID = resourceID
        self.VCSID = resourceID
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.owner, forKey: CodingKeys.owner)
        try container.encode(self.container, forKey: CodingKeys.container)
        try container.encode(self.provider, forKey: CodingKeys.provider)
        try container.encode(self.fileType, forKey: CodingKeys.fileType)
        try container.encode(self.path, forKey: CodingKeys.path)
        try container.encode(self.id, forKey: CodingKeys.id)
        try container.encode(self.versionID, forKey: CodingKeys.versionID)
        try container.encode(self.resourceID, forKey: CodingKeys.resourceID)
    }
    
    init(VCSID: String, id: Int, owner: String, container: String, provider: String, fileType: String, path: String, versionID: String, resourceID: String) {
        self.id = id
        self.owner = owner
        self.container = container
        self.provider = provider
        self.fileType = fileType
        self.path = path
        self.versionID = versionID
        self.resourceID = resourceID
        self.VCSID = VCSID
    }
}

extension VCSJobFileVersionResponse: VCSCacheable {
    public var rID: String { return owner + path }
}
