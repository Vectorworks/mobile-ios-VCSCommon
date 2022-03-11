import Foundation

@objc public class WSharedWithInfo: NSObject, Codable {
    @objc public let email, login, username: String
    @objc public let permissions: [String] // the raw value is string
    @objc public let hasJoined: Bool
    
    enum CodingKeys: String, CodingKey {
        case email, login, username, permissions
        case hasJoined = "has_joined"
    }
    
    public init(email: String, login: String, username: String, permissions: [String], hasJoined: Bool) {
        self.email = email
        self.login = login
        self.username = username
        self.permissions = permissions
        self.hasJoined = hasJoined
    }
}
