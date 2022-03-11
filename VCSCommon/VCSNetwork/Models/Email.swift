import Foundation

@objc public class Email: NSObject, Codable {
    public let email: String
    public let isVerified: Bool
    
    init(email: String, isVerified: Bool) {
        self.email = email
        self.isVerified = isVerified
    }
    
    enum CodingKeys: String, CodingKey {
        case email
        case isVerified = "is_verified"
    }
}
