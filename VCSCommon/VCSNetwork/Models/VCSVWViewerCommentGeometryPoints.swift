import Foundation

public struct VCSVWViewerCommentGeometryPoints: Codable {
    public let top: Double
    public let left: Double
    public let page: VCSVWViewerCommentPage
    public let vectorworksCoordinates: VCSVWViewerCommentGeometryVectorworkCoordinates

    enum CodingKeys: String, CodingKey {
        case top = "top"
        case left = "left"
        case page = "page"
        case vectorworksCoordinates = "vectorworksCoordinates"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        top = try values.decode(Double.self, forKey: .top)
        left = try values.decode(Double.self, forKey: .left)
        page = try values.decode(VCSVWViewerCommentPage.self, forKey: .page)
        vectorworksCoordinates = try values.decode(VCSVWViewerCommentGeometryVectorworkCoordinates.self, forKey: .vectorworksCoordinates)
    }
    
    public init(top: Double, left: Double, page: VCSVWViewerCommentPage, vectorworksCoordinates: VCSVWViewerCommentGeometryVectorworkCoordinates) {
        self.top = top
        self.left = left
        self.page = page
        self.vectorworksCoordinates = vectorworksCoordinates
    }
}
