import Foundation
import SwiftData

public class JobsResponse: NSObject, Codable {
    public let count: Int
    public let next: String?
    public let previous: String?
    public let results: [VCSJobResponse]
}

@Model
public final class VCSJobResponse: Codable {
    public let id: Int
    public let user: String
    public let fileVersion: VCSJobFileVersionResponse?
    public let vw: Int?
    public var jobType: String
    public var status: String
    public var statusData: String
    public var lastUpdate: String
    public let userData: String
    public var timeRemaining: Int
    public let submissionTimestamp: String
    public let startTimestamp: String
    public let endTimestamp: String
    public let outputfile: String
    public var usedPUs: Double
    public var usedFUs: Double
    public let options: VCSJobOptionsResponse?
    public let origin: String
    public var sequenceNumber: Int?
    
    public var lastEvent: VCSJobEventResponse?
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int.self, forKey: CodingKeys.id)
        self.user = try container.decode(String.self, forKey: CodingKeys.user)
        self.fileVersion = try container.decode(VCSJobFileVersionResponse?.self, forKey: CodingKeys.fileVersion)
        self.vw = try container.decode(Int?.self, forKey: CodingKeys.vw)
        self.jobType = try container.decode(String.self, forKey: CodingKeys.jobType)
        self.status = try container.decode(String.self, forKey: CodingKeys.status)
        self.statusData = try container.decode(String.self, forKey: CodingKeys.statusData)
        self.lastUpdate = try container.decode(String.self, forKey: CodingKeys.lastUpdate)
        self.userData = try container.decode(String.self, forKey: CodingKeys.userData)
        self.timeRemaining = try container.decode(Int.self, forKey: CodingKeys.timeRemaining)
        self.submissionTimestamp = try container.decode(String.self, forKey: CodingKeys.submissionTimestamp)
        self.startTimestamp = try container.decode(String.self, forKey: CodingKeys.startTimestamp)
        self.endTimestamp = try container.decode(String.self, forKey: CodingKeys.endTimestamp)
        self.outputfile = try container.decode(String.self, forKey: CodingKeys.outputfile)
        self.usedPUs = try container.decode(Double.self, forKey: CodingKeys.usedPUs)
        self.usedFUs = try container.decode(Double.self, forKey: CodingKeys.usedFUs)
        self.options = try container.decode(VCSJobOptionsResponse?.self, forKey: CodingKeys.options)
        self.origin = try container.decode(String.self, forKey: CodingKeys.origin)
        self.sequenceNumber = try container.decode(Int?.self, forKey: CodingKeys.sequenceNumber)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.id, forKey: CodingKeys.id)
        try container.encode(self.user, forKey: CodingKeys.user)
        try container.encode(self.fileVersion, forKey: CodingKeys.fileVersion)
        try container.encode(self.vw, forKey: CodingKeys.vw)
        try container.encode(self.jobType, forKey: CodingKeys.jobType)
        try container.encode(self.status, forKey: CodingKeys.status)
        try container.encode(self.statusData, forKey: CodingKeys.statusData)
        try container.encode(self.lastUpdate, forKey: CodingKeys.lastUpdate)
        try container.encode(self.userData, forKey: CodingKeys.userData)
        try container.encode(self.timeRemaining, forKey: CodingKeys.timeRemaining)
        try container.encode(self.submissionTimestamp, forKey: CodingKeys.submissionTimestamp)
        try container.encode(self.startTimestamp, forKey: CodingKeys.startTimestamp)
        try container.encode(self.endTimestamp, forKey: CodingKeys.endTimestamp)
        try container.encode(self.outputfile, forKey: CodingKeys.outputfile)
        try container.encode(self.usedPUs, forKey: CodingKeys.usedPUs)
        try container.encode(self.usedFUs, forKey: CodingKeys.usedFUs)
        try container.encode(self.options, forKey: CodingKeys.options)
        try container.encode(self.origin, forKey: CodingKeys.origin)
        try container.encode(self.sequenceNumber, forKey: CodingKeys.sequenceNumber)
    }
    
    public var computedVW: Int { return self.vw ?? 0 }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case user
        case fileVersion = "file_version"
        case vw
        case jobType = "job_type"
        case status, statusData, lastUpdate
        case userData = "user_data"
        case timeRemaining, submissionTimestamp, startTimestamp, endTimestamp, outputfile, usedPUs, usedFUs, options, origin, sequenceNumber
    }
    
    init(id: Int, user: String, fileVersion: VCSJobFileVersionResponse?, vw: Int?, jobType: String, status: String, statusData: String, lastUpdate: String,
         userData: String, timeRemaining: Int, submissionTimestamp: String, startTimestamp: String, endTimestamp: String, outputfile: String,
         usedPUs: Double, usedFUs: Double, options: VCSJobOptionsResponse?, origin: String, lastEvent: VCSJobEventResponse?) {
        self.id = id
        self.user = user
        self.fileVersion = fileVersion
        self.vw = vw
        self.jobType = jobType
        self.status = status
        self.statusData = statusData
        self.lastUpdate = lastUpdate
        self.userData = userData
        self.timeRemaining = timeRemaining
        self.submissionTimestamp = submissionTimestamp
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
        self.outputfile = outputfile
        self.usedPUs = usedPUs
        self.usedFUs = usedFUs
        self.options = options
        self.origin = origin
        self.lastEvent = lastEvent
    }
    
    
}

extension VCSJobResponse: VCSCacheable {
    public var rID: String { return user + jobType  }
}
