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

public enum PresentationDownloadJobState: String {
    case prepare = "prepare"
    case progress = "progress"
    case done = "done"
}

public class VCSJobEventResponse: Codable {
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

public struct DownloadPresentationJobEventNotificationResponse: Decodable {
    public var packetType: String
    public var channel: String
    public var jobData: DownloadPresentationJobData
    
    enum CodingKeys: String, CodingKey {
        case packetType = "packet_type"
        case channel = "topic_id"
        case jobData = "data"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.packetType = try container.decode(String.self, forKey: CodingKeys.packetType)
        self.channel = try container.decode(String.self, forKey: CodingKeys.channel)
        self.jobData = try container.decode(DownloadPresentationJobData.self, forKey: CodingKeys.jobData)
    }
}

public struct DownloadPresentationJobData: Decodable {
    public var event: String
    var username: String
    public var data: VCSDownloadPresentationEventResponseData
}

public class VCSDownloadPresentationEventResponseData: Codable {
    public let presentation: VCSPresentation
    public let job: VCSDownloadPresentationJob
    public let event: String
    public let timestamp: String
    public let sequenceNumber: Int

    enum CodingKeys: String, CodingKey {
        case presentation = "presentation"
        case job = "job"
        case event = "event"
        case timestamp = "timestamp"
        case sequenceNumber = "sequence_number"
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        presentation = try values.decode(VCSPresentation.self, forKey: .presentation)
        job = try values.decode(VCSDownloadPresentationJob.self, forKey: .job)
        event = try values.decode(String.self, forKey: .event)
        timestamp = try values.decode(String.self, forKey: .timestamp)
        sequenceNumber = try values.decode(Int.self, forKey: .sequenceNumber)
    }
}

public class VCSDownloadPresentationJob: Codable {
    public let id: Int
    public let type: String
    public let presentation: VCSPresentation
    public let state: String
    public let error: String?
    public let progress: Int
    public let downloadUrl: String?
    public let dateCreated: String
    public let dateModified: String
    public let resultFile: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case presentation = "presentation"
        case state = "state"
        case error = "error"
        case progress = "progress"
        case downloadUrl = "download_url"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
        case resultFile = "result_file"
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: CodingKeys.id)
        type = try values.decode(String.self, forKey: CodingKeys.type)
        presentation = try values.decode(VCSPresentation.self, forKey: CodingKeys.presentation)
        state = try values.decode(String.self, forKey: CodingKeys.state)
        error = try values.decodeIfPresent(String.self, forKey: CodingKeys.error)
        progress = try values.decode(Int.self, forKey: CodingKeys.progress)
        downloadUrl = try values.decodeIfPresent(String.self, forKey: CodingKeys.downloadUrl)
        dateCreated = try values.decode(String.self, forKey: CodingKeys.dateCreated)
        dateModified = try values.decode(String.self, forKey: CodingKeys.dateModified)
        resultFile = try values.decodeIfPresent(Int.self, forKey: CodingKeys.resultFile)
    }

}

public class VCSPresentation : Codable, Hashable {
    public static func == (lhs: VCSPresentation, rhs: VCSPresentation) -> Bool {
        return lhs.uuid == rhs.uuid && lhs.title == rhs.title
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
        hasher.combine(title)
    }
    
    public let uuid : String
    public let title : String

    enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case title = "title"
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try values.decode(String.self, forKey: .uuid)
        title = try values.decode(String.self, forKey: .title)
    }
}

public struct VCDOCCommentEventNotificationResponse: Decodable {
    public var packetType: String
    public var channel: String
    public var data: VCDOCCommentEventData
    
    enum CodingKeys: String, CodingKey {
        case packetType = "packet_type"
        case channel = "topic_id"
        case data = "data"
    }
}

public struct VCDOCCommentEventData: Decodable {
    public var event: String
    var username: String
    public var data: VCDOCCommentEventResponseData
}

public struct VCDOCCommentEventResponseData: Decodable {
    public var comment: VCDOCCommentEventResponseCommentData
    public var event: String
    public var action: String
    public var toast: Bool
    public var timestamp: String
    public var sequenceNumber: Int
    
    enum CodingKeys: String, CodingKey {
        case comment = "comment"
        case event = "event"
        case action = "action"
        case toast = "toast"
        case timestamp = "timestamp"
        case sequenceNumber = "sequence_number"
    }
}

public class VCDOCCommentEventResponseCommentData: Codable {
    public let id: Int
    public let owner: VCDOCCommentEventResponseCommentOwnerData
    public let content: String
    public let pubDate: String
    public let modDate: String
    public let parentID: Int?
    public let resolved: Bool?
    public let replies: [VCSVWViewerCommentReply]?
    public let metadata: VCSVWViewerCommentMetadata?
    public let resource: VCDOCCommentEventResourceData
    public let resourceType: String
    public let linkUUID: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case owner = "owner"
        case content = "content"
        case pubDate = "pub_date"
        case modDate = "mod_date"
        case parentID = "parent"
        case resolved = "resolved"
        case replies = "replies"
        case metadata = "metadata"
        case resource = "resource"
        case resourceType = "resource_type"
        case linkUUID = "link_uuid"
    }

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        owner = try values.decode(VCDOCCommentEventResponseCommentOwnerData.self, forKey: .owner)
        content = try values.decode(String.self, forKey: .content)
        pubDate = try values.decode(String.self, forKey: .pubDate)
        modDate = try values.decode(String.self, forKey: .modDate)
        parentID = try values.decodeIfPresent(Int.self, forKey: .parentID)
        resolved = try values.decodeIfPresent(Bool.self, forKey: .resolved)
        replies = try values.decodeIfPresent([VCSVWViewerCommentReply].self, forKey: .replies)
        metadata = try values.decodeIfPresent(VCSVWViewerCommentMetadata.self, forKey: .metadata)
        resource = try values.decode(VCDOCCommentEventResourceData.self, forKey: .resource)
        resourceType = try values.decode(String.self, forKey: .resourceType)
        linkUUID = try values.decodeIfPresent(String.self, forKey: .linkUUID)
    }
}

public struct VCDOCCommentEventResourceData: Codable {
    public var id: Int
    public var object: VCSVWViewerCommentResourceObject
}


public class VCDOCCommentEventResponseCommentOwnerData: Codable {
    public let id: Int
    public let firstName: String
    public let lastName: String
    public let email: String
    public let login: String
    public let nvwuid: String
    public let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email = "email"
        case login = "login"
        case nvwuid = "nvwuid"
        case fullName = "full_name"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        firstName = try values.decode(String.self, forKey: .firstName)
        lastName = try values.decode(String.self, forKey: .lastName)
        email = try values.decode(String.self, forKey: .email)
        login = try values.decode(String.self, forKey: .login)
        nvwuid = try values.decode(String.self, forKey: .nvwuid)
        fullName = try values.decode(String.self, forKey: .fullName)
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
