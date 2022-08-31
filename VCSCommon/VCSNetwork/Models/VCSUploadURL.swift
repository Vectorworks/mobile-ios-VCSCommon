import Foundation

@objc public class VCSUploadURL: NSObject, Decodable {
    @objc public let url: String
    public let contentLength: Int
    public var uploadMethod: String?
    public let contentType: String
    public let headers: Headers
    
    enum CodingKeys: String, CodingKey {
        case url
        case contentLength = "content_length"
        case uploadMethod = "upload_method"
        case contentType = "content_type"
        case headers
    }
}

public struct Headers: Codable {
    public let dropboxAPIPathRoot: String?
    public let dropboxAPIArg: String?
    public let authorization: String?
    public let contentLength: String?
    public let contentType: String?
    public let contentRange: String?
    
    enum CodingKeys: String, CodingKey {
        case dropboxAPIPathRoot = "Dropbox-API-Path-Root"
        case dropboxAPIArg = "Dropbox-API-Arg"
        case authorization = "Authorization"
        case contentLength = "Content-Length"
        case contentType = "Content-Type"
        case contentRange = "Content-Range"
    }
}
