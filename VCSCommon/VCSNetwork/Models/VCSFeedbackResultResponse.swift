import Foundation

public class VCSFeedbackResultResponse: NSObject, Codable {
    public let hasSent: Bool
    
    enum CodingKeys: String, CodingKey {
        case hasSent = "has_sent"
    }
}
