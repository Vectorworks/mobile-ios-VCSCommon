import Foundation

public class VCSFeedbackResultResponse: Codable {
    public let hasSent: Bool
    
    enum CodingKeys: String, CodingKey {
        case hasSent = "has_sent"
    }
}
