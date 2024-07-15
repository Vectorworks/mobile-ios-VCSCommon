import Foundation

public struct VCSVWViewerCommentResourceObject: Codable {
    public let owner: String
    public let provider: String
    public let container: String
    public let path: String
    public let versionID: String
    public let id: Int
    public let fileType: String
    public let isFolder: Bool
    public let srcID: String
    public let resourceID: String

    enum CodingKeys: String, CodingKey {
        case owner = "owner"
        case provider = "provider"
        case container = "container"
        case path = "path"
        case versionID = "version_id"
        case id = "id"
        case fileType = "file_type"
        case isFolder = "is_folder"
        case srcID = "src_id"
        case resourceID = "resource_id"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        owner = try values.decode(String.self, forKey: .owner)
        provider = try values.decode(String.self, forKey: .provider)
        container = try values.decode(String.self, forKey: .container)
        path = try values.decode(String.self, forKey: .path)
        versionID = try values.decode(String.self, forKey: .versionID)
        id = try values.decode(Int.self, forKey: .id)
        fileType = try values.decode(String.self, forKey: .fileType)
        isFolder = try values.decode(Bool.self, forKey: .isFolder)
        srcID = try values.decode(String.self, forKey: .srcID)
        resourceID = try values.decode(String.self, forKey: .resourceID)
    }
}
