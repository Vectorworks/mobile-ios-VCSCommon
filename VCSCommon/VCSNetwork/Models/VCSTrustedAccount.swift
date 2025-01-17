import Foundation

public struct VCSTrustedAccount: Codable, Identifiable, Hashable {
    public let id: Int
    public let login: String
    public let email: String
    let firstName: String
    let lastName: String
    let nvwuid: String
    public let fullName: String
    let organizations: [String]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case login = "login"
        case email = "email"
        case firstName = "first_name"
        case lastName = "last_name"
        case nvwuid = "nvwuid"
        case fullName = "full_name"
        case organizations = "organizations"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        login = try values.decode(String.self, forKey: .login)
        email = try values.decode(String.self, forKey: .email)
        firstName = try values.decode(String.self, forKey: .firstName)
        lastName = try values.decode(String.self, forKey: .lastName)
        nvwuid = try values.decode(String.self, forKey: .nvwuid)
        fullName = try values.decode(String.self, forKey: .fullName)
        organizations = try values.decode([String].self, forKey: .organizations)
    }
}
