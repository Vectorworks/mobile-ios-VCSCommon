import Foundation

public class VCSVWViewerResolveCommentRequest: NSObject, Codable {
    let id: Int
    let mentions: [String]
    let resolved: Bool

    
    public enum CodingKeys: String, CodingKey {
        case id
        case mentions
        case resolved
    }
    
    public init(id: Int, mentions: [String], resolved: Bool) {
        self.id = id
        self.mentions = mentions
        self.resolved = resolved
    }
}
