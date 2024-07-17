import Foundation

public class VCSVWViewerReplyRequest: NSObject, Codable {
    let parentID: Int
    let content: String
    let mentions: [VCSVWViewerMentionedUser]
    
    enum CodingKeys: String, CodingKey {
        case parentID = "parent"
        case content = "content"
        case mentions = "mentions"
    }
    
    public init(parentID: Int, content: String, mentions: [VCSVWViewerMentionedUser]) {
        self.parentID = parentID
        self.content = content
        self.mentions = mentions
    }
}
