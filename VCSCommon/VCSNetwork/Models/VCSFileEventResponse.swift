import Foundation

public struct JobResult: Decodable {
    public var asset: AssetData
    public var file: VCSFileResponse
    public var related: [AssetData]
    public var thumbnailURL: String
    
    enum CodingKeys: String, CodingKey {
        case asset, related
        case thumbnailURL = "thumbnail_url"
        case file = "data"
    }
}

public struct AssetData: Decodable {
    //TODO: test changes
    public var versionID: String
    public var path: String
    public var storageType: String
    public var owner: String
    public var fileType: String
    public let resourceID: String
    
    enum CodingKeys: String, CodingKey {
        case versionID = "version_id"
        case storageType = "storage_type"
        case fileType = "file_type"
        case resourceID = "resource_id"
        case path, owner
    }
    
    public var rID: String { return resourceID }
}

public enum FileEventResponseContentType {
    case file(VCSFileResponse)
    case thumbnailURL(String)
    case delete(Bool)
    case relatedFiles([VCSFileResponse])
    case error(String)
    case jobResults([JobResult])
}

public enum DecodingFileEventError: Error {
    case responseContentError
}

public struct FileEventData: Decodable {
    
    var asset: AssetData
    var eventData: Result<FileEventResponseContentType, DecodingFileEventError>
    
    enum CodingKeys: String, CodingKey {
        case asset, permanent
        case file = "data"
        case thumbnailURL = "thumbnail_url"
        case relatedFiles = "related"
        case jobResults = "results"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.asset = try container.decode(AssetData.self, forKey: CodingKeys.asset)
        
        if let file = try? container.decode(VCSFileResponse.self, forKey: CodingKeys.file) {
            self.eventData = .success(.file(file))
        } else if let url = try? container.decode(String.self, forKey: CodingKeys.thumbnailURL) {
            self.eventData = .success(.thumbnailURL(url))
        } else if let permanent = try? container.decode(Bool.self, forKey: CodingKeys.permanent) {
            self.eventData = .success(.delete(permanent))
        } else if let files = try? container.decode([VCSFileResponse].self, forKey: CodingKeys.relatedFiles) {
            self.eventData = .success(.relatedFiles(files))
        } else if let jobResult = try? container.decode([JobResult].self, forKey: CodingKeys.jobResults) {
            self.eventData = .success(.jobResults(jobResult))
        } else {
            self.eventData = .failure(.responseContentError)
        }   
    }
}

public struct FilePayload: Decodable {
    var event: String
    var data: FileEventData
}

public enum FileEventResponseContent {
    case create(VCSFileResponse)
}

public struct FileEventNotificationResponse: Decodable {
    
    public enum FileEvent: String {
        case delete, create
        case newVersion = "new_version"
        case newThumbnail = "new_thumbnail"
        case newRelatedFilesAdded = "related_files_added"
        case jobCompleted = "job_completed"
    }
    
    public var channel: String
    public var asset: AssetData
    
    public var event: FileEvent?
    public var content: Result<FileEventResponseContentType, DecodingFileEventError>
    
    enum CodingKeys: String, CodingKey {
        case channel = "topic_id"
        case payload = "data"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let payload = try container.decode(FilePayload.self, forKey: CodingKeys.payload)
        
        self.event = FileEvent(rawValue: payload.event)
        self.asset = payload.data.asset
        self.content = payload.data.eventData
        
        self.channel = try container.decode(String.self, forKey: CodingKeys.channel)
    }
}
