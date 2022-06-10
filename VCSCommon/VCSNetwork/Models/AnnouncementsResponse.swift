import Foundation

public class AnnouncementsResponse: NSObject, Codable {
    public let unseen: [Int]
}

public class ClearNotificationHolder: NSObject, Codable {
    public let sequenceNumbers: [Int]
    
    enum CodingKeys: String, CodingKey {
        case sequenceNumbers = "sequence_numbers"
    }
    
    public init(withIDs: [Int]) {
        self.sequenceNumbers = withIDs
    }
}
