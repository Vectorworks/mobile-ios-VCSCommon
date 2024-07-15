import Foundation

public struct VCSVWViewerCommentReplyOwner: Codable {
    public let id: Int
    public let firstName: String
    public let lastName: String
    public let email: String
    public let login: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
        case login = "login"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        firstName = try values.decode(String.self, forKey: .firstName)
        lastName = try values.decode(String.self, forKey: .lastName)
        email = try values.decode(String.self, forKey: .email)
        login = try values.decode(String.self, forKey: .login)
    }
}
