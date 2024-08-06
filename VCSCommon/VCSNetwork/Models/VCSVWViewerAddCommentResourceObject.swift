import Foundation

public struct VCSVWViewerAddCommentResourceObject: Codable {
    let versionID: String
    let owner: String
    let provider: String
    let path: String
    
    public enum CodingKeys: String, CodingKey {
        case versionID = "version_id"
        case owner
        case provider
        case path
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.versionID = try container.decode(String.self, forKey: .versionID)
        self.owner = try container.decode(String.self, forKey: .owner)
        self.provider = try container.decode(String.self, forKey: .provider)
        self.path = try container.decode(String.self, forKey: .path)
    }
    
    public init(versionID: String, owner: String, provider: String, path: String) {
        self.versionID = versionID
        self.owner = owner
        self.provider = provider
        self.path = path
    }
}
