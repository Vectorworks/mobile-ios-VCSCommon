import Foundation

// MARK: - SharedFolderResponse
public class VCSAccessTokenResponse: Codable {
    public let accessToken: String
    public let expiresIn: Int
    public let tokenType: String
    public let scope: String
    public let refreshToken: String
    
    public init(testOnlyOldAPIToken: String) {
        self.accessToken = testOnlyOldAPIToken
        self.expiresIn = 0
        self.tokenType = ""
        self.scope = ""
        self.refreshToken = ""
    }

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case scope = "scope"
        case refreshToken = "refresh_token"
    }
}
