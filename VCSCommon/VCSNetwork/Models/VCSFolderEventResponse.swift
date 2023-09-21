import Foundation

struct FolderEventData: Decodable {
    var folder: VCSFolderResponse
    
    enum CodingKeys: String, CodingKey {
        case folder = "data"
    }
}

struct FolderPayload: Decodable {
    var event: String
    var data: FolderEventData
}

public struct FolderEventNotificationResponse: Decodable {
    
    public enum FolderEvent: String {
        case delete, restore, create 
    }
    
    public var channel: String
    public var event: FolderEvent?
    public var folder: VCSFolderResponse
    
    enum CodingKeys: String, CodingKey {
        case channel = "topic_id"
        case payload = "data"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let payload = try container.decode(FolderPayload.self, forKey: CodingKeys.payload)
        
        self.event = FolderEvent(rawValue: payload.event)
        self.folder = payload.data.folder
        self.channel = try container.decode(String.self, forKey: CodingKeys.channel)
    }
}
