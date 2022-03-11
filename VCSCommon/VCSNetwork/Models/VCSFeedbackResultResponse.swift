import Foundation

@objc public class VCSFeedbackResultResponse: NSObject, Codable {
    @objc public let hasSent: Bool
    
    enum CodingKeys: String, CodingKey {
        case hasSent = "has_sent"
    }
}
