import Foundation

public class SSOUserResponse: Codable {
    public let status, detail: String
    public let user: VCSSSOUser
}
