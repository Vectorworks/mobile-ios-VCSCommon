import Foundation

public struct VCSVWViewerCommentGeometryVectorworkCoordinates: Codable {
    public let x: CGFloat
    public let y: CGFloat
    
    enum CodingKeys: String, CodingKey {
        case x = "x"
        case y = "y"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        x = try container.decode(CGFloat.self, forKey: .x)
        y = try container.decode(CGFloat.self, forKey: .y)
    }
}
