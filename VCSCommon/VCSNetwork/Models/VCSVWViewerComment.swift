import Foundation

public struct VCSVWViewerComment: Codable {
    public let id: Int
    public let owner: VCSVWViewerCommentOwner
    public let resource: VCSVWViewerCommentResource
    public let content: String
    public let pubDate: String
    public let modDate: String
    public let resolved: Bool
    public let replies: [VCSVWViewerCommentReply]
    public let metadata: VCSVWViewerCommentMetadata

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case owner = "owner"
        case resource = "resource"
        case content = "content"
        case pubDate = "pub_date"
        case modDate = "mod_date"
        case resolved = "resolved"
        case replies = "replies"
        case metadata = "metadata"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        owner = try values.decode(VCSVWViewerCommentOwner.self, forKey: .owner)
        resource = try values.decode(VCSVWViewerCommentResource.self, forKey: .resource)
        content = try values.decode(String.self, forKey: .content)
        pubDate = try values.decode(String.self, forKey: .pubDate)
        modDate = try values.decode(String.self, forKey: .modDate)
        resolved = try values.decode(Bool.self, forKey: .resolved)
        replies = try values.decode([VCSVWViewerCommentReply].self, forKey: .replies)
        metadata = try values.decode(VCSVWViewerCommentMetadata.self, forKey: .metadata)
    }
}
