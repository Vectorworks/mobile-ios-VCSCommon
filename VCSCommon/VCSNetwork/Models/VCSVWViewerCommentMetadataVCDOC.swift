import Foundation

public struct VCSVWViewerCommentMetadataVCDOC: Codable {
    public let geometry: VCSVWViewerCommentMetadataVCDOCGeometry
    public let pageNumber: Int

    enum CodingKeys: String, CodingKey {
        case geometry = "geometry"
        case pageNumber = "pageNumber"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        geometry = try values.decode(VCSVWViewerCommentMetadataVCDOCGeometry.self, forKey: .geometry)
        pageNumber = try values.decode(Int.self, forKey: .pageNumber)
    }
}
