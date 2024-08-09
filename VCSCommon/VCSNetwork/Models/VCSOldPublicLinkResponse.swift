import Foundation

public class VCSOldPublicLinkResponse: Codable {
    public let dateCreated: String
    public let expired: Bool
    public let expires: String
    public let oldPublicLinkPublic: Bool
    public let resourceURI, s3File, storageType, url: String
    
    enum CodingKeys: String, CodingKey {
        case dateCreated = "date_created"
        case expired, expires
        case oldPublicLinkPublic = "public"
        case resourceURI = "resource_uri"
        case s3File = "s3file"
        case storageType = "storage_type"
        case url
    }
}
