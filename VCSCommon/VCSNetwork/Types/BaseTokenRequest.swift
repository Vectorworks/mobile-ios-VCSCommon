import Foundation

public class BaseTokenRequest: NSObject, Codable {
    public let clientID: String
    
    public let grantType: String //= "authorization_code"
    
    public let redirectURI: String?
    public let codeVerifier: String?
    
    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        
        case grantType = "grant_type"
        
        case redirectURI = "redirect_uri"
        case codeVerifier = "code_verifier"
    }
    
    @objc public init(clientID: String, grantType: String, redirectURI: String? = nil, codeVerifier: String? = nil) {
        self.clientID = clientID
        
        self.grantType = grantType
        
        self.redirectURI = redirectURI
        self.codeVerifier = codeVerifier
    }
}
