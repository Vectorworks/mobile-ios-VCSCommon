import Foundation

public struct VCSVWViewerCommentResource: Codable {
    public let id: Int
    public let object: VCSVWViewerCommentResourceObject
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case object = "object"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        object = try values.decode(VCSVWViewerCommentResourceObject.self, forKey: .object)
    }
}
