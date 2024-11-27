import Foundation

public class VCSVWViewerEditCommentRequest: NSObject, Codable {
    let content: String
    let id: Int
    let mentions: [String]

    
    public enum CodingKeys: String, CodingKey {
        case content
        case id
        case mentions
    }
    
    public init(content: String, id: Int, mentions: [String]) {
        self.content = content
        self.id = id
        self.mentions = mentions
    }
}

