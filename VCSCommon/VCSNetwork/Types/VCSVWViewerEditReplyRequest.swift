import Foundation

public class VCSVWViewerEditReplyRequest: Codable {
    let content: String
    let id: Int
    let mentions: [VCSVWViewerMentionedUser]
    
    public init(content: String, id: Int, mentions: [VCSVWViewerMentionedUser]) {
        self.content = content
        self.id = id
        self.mentions = mentions
    }
}
