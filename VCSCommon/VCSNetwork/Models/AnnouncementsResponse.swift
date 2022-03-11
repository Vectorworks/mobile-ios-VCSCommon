import Foundation

@objc public class AnnouncementsResponse: NSObject, Codable {
    public let meta: MetaResponse
    @objc public let objects: [VCSAnnouncementResponse]
}

@objc public class MetaResponse: NSObject, Codable {
    public let limit: Int
    public let next: String?
    public let offset: Int
    public let previous: String?
    public let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case limit, next, offset, previous
        case totalCount = "total_count"
    }
}
