import Foundation

public class VCSVWViewerAddCommentRequest: NSObject, Codable {
    let content: String
    let mentions: [String]
    let metadata: VCSVWViewerCommentMetadata
    let resource: VCSVWViewerAddCommentResource
    
    public enum CodingKeys: String, CodingKey {
        case content
        case mentions
        case metadata
        case resource
    }
    
    public init(content: String, mentions: [String], metadata: VCSVWViewerCommentMetadata, resource: VCSVWViewerAddCommentResource) {
        self.content = content
        self.mentions = mentions
        self.metadata = metadata
        self.resource = resource
    }
}
