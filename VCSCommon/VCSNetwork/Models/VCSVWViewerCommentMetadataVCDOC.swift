import Foundation

public struct VCSVWViewerCommentMetadataVCDOC: Codable {
    public let pageNumber: Int
    public let geometry: VCSVWViewerCommentMetadataVCDOCGeometry
    
    
    enum CodingKeys: String, CodingKey {
        case pageNumber = "pageNumber"
        case geometry = "geometry"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        pageNumber = try values.decode(Int.self, forKey: .pageNumber)
        geometry = try values.decode(VCSVWViewerCommentMetadataVCDOCGeometry.self, forKey: .geometry)
    }
    
    public init(pageNumber: Int, geometry: VCSVWViewerCommentMetadataVCDOCGeometry) {
        self.pageNumber = pageNumber
        self.geometry = geometry
    }
}
