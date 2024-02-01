import Foundation

public enum JobStatus: String {
    case preparing = "preparing"
    case ready = "ready"
    case scheduled = "scheduled"
    case queued = "queued"
    case pickedup = "pickedup"
    case processing = "processing"
    case complete = "complete"
    case failed = "failed"
    case canceled = "canceled"
}

public class VCSJobEventResponse: NSObject, Codable {
    public let id: Int
    public let jobType: String
    public let lastUpdate: String
    public let sequenceNumber: Int
    public let status: String
    public let statusData: String
    public let storageType: String
    public let timeRemaining: Int
    public let timestamp: String
    public let usedPUs: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case jobType = "job_type"
        case lastUpdate = "last_update"
        case sequenceNumber = "sequence_number"
        case status
        case statusData
        case storageType = "storage_type"
        case timeRemaining = "time_remaining"
        case timestamp
        case usedPUs
    }
    
    init(id: Int, jobType: String, lastUpdate: String, sequenceNumber: Int, status: String, statusData: String, storageType: String, timeRemaining: Int, timestamp: String, usedPUs: Double) {
        self.id = id
        self.jobType = jobType
        self.lastUpdate = lastUpdate
        self.sequenceNumber = sequenceNumber
        self.status = status
        self.statusData = statusData
        self.storageType = storageType
        self.timeRemaining = timeRemaining
        self.timestamp = timestamp
        self.usedPUs = usedPUs
    }
}

public struct JobPayload: Decodable {
    var event: String
    var username: String
    var data: VCSJobEventResponse
}

public struct JobEventNotificationResponse: Decodable {
    public var channel: String
    
    
    public var event: String?
    public var username: String?
    public var jobData: VCSJobEventResponse
    
    enum CodingKeys: String, CodingKey {
        case channel = "topic_id"
        case payload = "data"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.channel = try container.decode(String.self, forKey: CodingKeys.channel)
        
        let payload = try container.decode(JobPayload.self, forKey: CodingKeys.payload)
        self.event = payload.event
        self.username = payload.username
        self.jobData = payload.data
    }
}
