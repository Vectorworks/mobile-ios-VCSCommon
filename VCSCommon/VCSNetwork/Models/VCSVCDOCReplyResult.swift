import Foundation

public class VCSVCDOCReplyResult: Codable {
    public let id: Int
    public let owner: VCSVWViewerCommentReplyOwner
    public let content: String
    public let pubDate: String
    public let modDate: String
    public let parentID: Int

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case owner = "owner"
        case content = "content"
        case pubDate = "pub_date"
        case modDate = "mod_date"
        case parentID = "parent"
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        owner = try values.decode(VCSVWViewerCommentReplyOwner.self, forKey: .owner)
        content = try values.decode(String.self, forKey: .content)
        pubDate = try values.decode(String.self, forKey: .pubDate)
        modDate = try values.decode(String.self, forKey: .modDate)
        parentID = try values.decode(Int.self, forKey: .parentID)
    }
}
