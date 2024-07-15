import Foundation

public struct VCSListVCDOCCommentsResponse: Codable {
    public let comments: [VCSVWViewerComment]
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()
        comments = try container.decode([VCSVWViewerComment].self)
    }
}
