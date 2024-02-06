import Foundation

public struct VCSPresentationOwner: Codable, Hashable {
    let id: Int
    let first_name: String
    let last_name: String
    let email: String
    let login: String

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case first_name = "first_name"
        case last_name = "last_name"
        case email = "email"
        case login = "login"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        first_name = try values.decode(String.self, forKey: .first_name)
        last_name = try values.decode(String.self, forKey: .last_name)
        email = try values.decode(String.self, forKey: .email)
        login = try values.decode(String.self, forKey: .login)
    }
}
