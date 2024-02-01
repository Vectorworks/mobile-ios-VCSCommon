import Foundation

public class SSOUserResponse: NSObject, Codable {
    public let status, detail: String
    public let user: VCSSSOUser
}
