import Foundation

public struct VCSTrustedAccountsResponse: Codable {
    public let trustedAccounts: [VCSTrustedAccount]
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.singleValueContainer()
        trustedAccounts = try container.decode([VCSTrustedAccount].self)
    }
}
