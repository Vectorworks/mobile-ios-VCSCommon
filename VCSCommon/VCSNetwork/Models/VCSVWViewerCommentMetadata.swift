import Foundation

public struct VCSVWViewerCommentMetadata: Codable {
    public let vcdoc: VCSVWViewerCommentMetadataVCDOC

    enum CodingKeys: String, CodingKey {
        case vcdoc = "vcdoc"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        vcdoc = try values.decode(VCSVWViewerCommentMetadataVCDOC.self, forKey: .vcdoc)
    }
}
