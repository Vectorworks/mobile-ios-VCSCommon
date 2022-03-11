import Foundation

public struct OldClientResponse: Codable {
    public let success: Bool
    public let reason: String
//    public let latestClients: LatestClients

    enum CodingKeys: String, CodingKey {
        case success, reason
//        case latestClients = "latest_clients"
    }
}

public struct LatestClients: Codable {
    public let latest: String
    public let urls: Urls
}

public struct Urls: Codable {
}
