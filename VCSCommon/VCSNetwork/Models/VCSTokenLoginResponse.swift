import Foundation

public class VCSTokenLoginResponse: NSObject, Codable {
    public let sessionKey, expireDate: String
    public let isExpired: Bool
    public let start, login: String
    public let user: VCSSSOUser
    
    enum CodingKeys: String, CodingKey {
        case sessionKey = "session_key"
        case expireDate = "expire_date"
        case isExpired = "is_expired"
        case start, login, user
    }
}
