import Foundation

public struct VCSVWViewerCommentGeometry: Codable {
    public let page: VCSVWViewerCommentPage
    public let points: [VCSVWViewerCommentGeometryPoints]
    public let displayName: String
    public let isPolyClosed: Bool
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case points = "points"
        case displayName = "displayName"
        case isPolyClosed = "isPolyClosed"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        page = try values.decode(VCSVWViewerCommentPage.self, forKey: .page)
        points = try values.decode([VCSVWViewerCommentGeometryPoints].self, forKey: .points)
        displayName = try values.decode(String.self, forKey: .displayName)
        isPolyClosed = try values.decode(Bool.self, forKey: .isPolyClosed)
    }
    
    public init(page: VCSVWViewerCommentPage, points: [VCSVWViewerCommentGeometryPoints], displayName: String, isPolyClosed: Bool) {
        self.page = page
        self.points = points
        self.displayName = displayName
        self.isPolyClosed = isPolyClosed
    }
}
