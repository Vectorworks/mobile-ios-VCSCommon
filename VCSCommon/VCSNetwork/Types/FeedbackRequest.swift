import Foundation

@objc public class FeedbackRequest: NSObject, Codable {
    public let token:String
    public let feedback:String
    public let category:String
    
    enum CodingKeys: String, CodingKey {
        case token = "csrfmiddlewaretoken"
        case feedback = "feedback_text"
        case category = "category_type"
    }
    
    @objc public init(token:String, feedback:String, category:String) {
        self.token = token
        self.feedback = feedback
        self.category = category
    }
}
