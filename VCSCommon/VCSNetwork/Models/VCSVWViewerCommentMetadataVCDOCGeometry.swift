import Foundation

public struct VCSVWViewerCommentMetadataVCDOCGeometry: Codable {
    public let id: String
    public let geometry: VCSVWViewerCommentGeometry

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case geometry = "geometry"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        geometry = try values.decode(VCSVWViewerCommentGeometry.self, forKey: .geometry)
    }
    
    public init(id: String, geometry: VCSVWViewerCommentGeometry) {
        self.id = id
        self.geometry = geometry
    }
}
