import Foundation

public class VCSAnnouncementSettingsResponse: NSObject, Codable {
    public let message: String
    public let dismissed: String?
    public let title: String
    public let url: String?
    public let accept: Accept?
    
    enum CodingKeys: String, CodingKey {
        case message = "description"
        case dismissed, title, url, accept
    }
}

public class Accept: NSObject, Codable {
    public let title, type, url: String
}
