import Foundation

public class AWSKeysResponse: NSObject, Codable {
    let meta: Meta
    public let objects: [VCSAWSKeysResponse]
}

public class VCSAWSKeysResponse: NSObject, Codable {
    public let s3ExpirationDate, s3Key, s3Secret, s3SecurityToken: String
    let expired: Bool
    let resourceURI, user: String
    
    enum CodingKeys: String, CodingKey {
        case s3ExpirationDate = "S3ExpirationDate"
        case s3Key = "S3Key"
        case s3Secret = "S3Secret"
        case s3SecurityToken = "S3SecurityToken"
        case expired
        case resourceURI = "resource_uri"
        case user
    }
}
