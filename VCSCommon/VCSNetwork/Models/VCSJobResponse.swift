import Foundation

public class JobsResponse: NSObject, Codable {
    public let count: Int
    public let next: String?
    public let previous: String?
    public let results: [VCSJobResponse]
}

public class VCSJobResponse: NSObject, Codable {
    public let id: Int
    public let user: String
    public let fileVersion: VCSJobFileVersionResponse?
    public let vw: Int?
    public var jobType, status, statusData, lastUpdate: String
    public let userData: String
    public var timeRemaining: Int
    public let submissionTimestamp, startTimestamp, endTimestamp, outputfile: String
    public var usedPUs, usedFUs: Double
    public let options: VCSJobOptionsResponse?
    public let origin: String
    public var sequenceNumber: Int?
    
    public var lastEvent: VCSJobEventResponse?
    
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

extension VCSJobResponse: VCSCachable {
    public typealias RealmModel = RealmJobData
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSJobResponse.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSJobResponse.realmStorage.getByIdOfItem(item: self) != nil {
            VCSJobResponse.realmStorage.partialUpdate(item: self)
        } else {
            VCSJobResponse.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSJobResponse.realmStorage.partialUpdate(item: self)
    }
}
