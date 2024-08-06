import Foundation

public struct VCSVWViewerAddCommentResource: Codable {
    public let resourceType: String
    public let object: VCSVWViewerAddCommentResourceObject
    
    public enum CodingKeys: String, CodingKey {
        case resourceType = "resource_type"
        case object
    }
    
    public init(resourceType: String, object: VCSVWViewerAddCommentResourceObject) {
        self.resourceType = resourceType
        self.object = object
    }
}
