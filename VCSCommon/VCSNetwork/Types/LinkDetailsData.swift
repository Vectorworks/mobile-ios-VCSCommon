import Foundation

public struct LinkDetailsData: Codable {
    public let linkType: String
    public let title: String?
    public let thumbnailURL: String?

    enum CodingKeys: String, CodingKey {
        case linkType = "link_type"
        case title
        case thumbnailURL = "thumbnail_url"
    }
}
