import Foundation

public class FeedbackRequest: Codable {
    public let csrftoken:String
    public let feedback:String
    public let category:String
    
    enum CodingKeys: String, CodingKey {
        case csrftoken = "csrfmiddlewaretoken"
        case feedback = "feedback_text"
        case category = "category_type"
    }
    
    public init(csrftoken:String, feedback:String, category:String) {
        self.csrftoken = csrftoken
        self.feedback = feedback
        self.category = category
    }
}
