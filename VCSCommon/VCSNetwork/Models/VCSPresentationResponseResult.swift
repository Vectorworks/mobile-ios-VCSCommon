import Foundation

public class VCSPresentationResponseResult: Codable, Hashable, Identifiable {
    public static func == (lhs: VCSPresentationResponseResult, rhs: VCSPresentationResponseResult) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    public var id: String { return uuid }
    
    public let uuid: String
    public let version: Int?
    public let title: String
    public let resource_uri: String
    public let date_created: String
    public let date_modified: String
    public let props: VCSPresentationProps
    public let owner: VCSPresentationOwner
    public let thumbnail: String?
    public let is_deleted: Bool

    enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case version = "version"
        case title = "title"
        case resource_uri = "resource_uri"
        case date_created = "date_created"
        case date_modified = "date_modified"
        case props = "props"
        case owner = "owner"
        case thumbnail = "thumbnail"
        case is_deleted = "is_deleted"
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try values.decode(String.self, forKey: .uuid)
        version = try values.decode(Int?.self, forKey: .version)
        title = try values.decode(String.self, forKey: .title)
        resource_uri = try values.decode(String.self, forKey: .resource_uri)
        date_created = try values.decode(String.self, forKey: .date_created)
        date_modified = try values.decode(String.self, forKey: .date_modified)
        props = try values.decode(VCSPresentationProps.self, forKey: .props)
        owner = try values.decode(VCSPresentationOwner.self, forKey: .owner)
        thumbnail = try values.decodeIfPresent(String.self, forKey: .thumbnail)
        is_deleted = try values.decode(Bool.self, forKey: .is_deleted)
    }

}
