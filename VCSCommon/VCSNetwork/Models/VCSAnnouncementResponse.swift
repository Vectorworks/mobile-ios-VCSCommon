import Foundation

@objc public class VCSAnnouncementResponse: NSObject, Codable {
    public let code: String
    public let id: Int
    @objc public let resourceURI: String
    @objc public let settings: VCSAnnouncementSettingsResponse
    public let shouldBeReadHandler, shouldSendHandler: String?
    
    enum CodingKeys: String, CodingKey {
        case code, id
        case resourceURI = "resource_uri"
        case settings
        case shouldBeReadHandler = "should_be_read_handler"
        case shouldSendHandler = "should_send_handler"
    }
}
