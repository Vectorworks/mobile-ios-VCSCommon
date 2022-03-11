import Foundation

@objc public class VCSAnnouncementSettingsResponse: NSObject, Codable {
    @objc public let message: String
    @objc public let dismissed: String?
    @objc public let title: String
    @objc public let url: String?
    @objc public let accept: Accept?
    
    enum CodingKeys: String, CodingKey {
        case message = "description"
        case dismissed, title, url, accept
    }
}

@objc public class Accept: NSObject, Codable {
    @objc public let title, type, url: String
}
