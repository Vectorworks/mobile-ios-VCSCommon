import Foundation
import CocoaLumberjackSwift

@objc public class UploadJob: NSObject {
    public enum JobType: String {
        case SingleFileUpload
        case MultipleFileUpload
        case PDFFileUpload
    }
    
    public static private(set) var uploadJobs: [UploadJob] = []
    
    
    public let jobID: String
    public let jobOperation: JobType
    public let localFiles: [UploadJobLocalFile]
    
    public init(jobID: String = UUID().uuidString, jobOperation: JobType = .MultipleFileUpload, localFiles: [UploadJobLocalFile]) {
        self.jobID = jobID
        self.jobOperation = jobOperation
        self.localFiles = localFiles
        super.init()
        if UploadJob.uploadJobs.contains(where: { $0.jobID == self.jobID }) == false {
            UploadJob.uploadJobs.append(self)
        }
        self.reCheckState()
    }
    
    public convenience init(jobID: String = UUID().uuidString, jobOperation: JobType = .SingleFileUpload, localFile: UploadJobLocalFile) {
        self.init(jobID: jobID, jobOperation: jobOperation, localFiles: [localFile])
    }
    
    func reCheckState() {
        DDLogInfo("UploadJob:reCheckState - \(self.localFiles.filter({ $0.uploadingState == .Done }).count) of \(self.localFiles.count)")
        guard self.localFiles.allSatisfy({ $0.uploadingState == .Done }) else { return }
        self.removeFromCache()
    }
}

public extension UploadJob {
    func startUploadOperations(completion: ((Result<VCSFileResponse, Error>) -> Void)? = nil) {        
        var operations: [Operation] = []
        switch self.jobOperation {
        case .SingleFileUpload:
            operations = getSimpleFileUpload(completion: completion)
        case .MultipleFileUpload:
            #warning("add completion handler")
            operations = getMultipleFileUpload()
        case .PDFFileUpload:
            operations = getPDFFileUpload(completion: completion)
        }
        
        VCSBackgroundSession.default.operationQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    private func getSimpleFileUpload(completion: ((Result<VCSFileResponse, Error>) -> Void)? = nil) -> [Operation] {
        guard let singleFile = self.localFiles.first, singleFile.uploadingState != .Done else { return [] }
        return SimpleFileUploadOperations().getOperations(localFile: singleFile, completion: completion)
    }
    
    private func getMultipleFileUpload(completion: ((Result<[VCSFileResponse], Error>) -> Void)? = nil) -> [Operation] {
        let localFiles = self.localFiles.filter { $0.uploadingState != .Done }
        return SimpleFileMultipleUploadsOperations().getOperations(localFiles: self.localFiles, completion: completion)
    }
    
    private func getPDFFileUpload(completion: ((Result<VCSFileResponse, Error>) -> Void)? = nil) -> [Operation] {
        guard let pdfFile = self.localFiles.first, pdfFile.uploadingState != .Done, pdfFile.related.allSatisfy({ $0.uploadingState != .Done }) else { return [] }
        #warning("handle pdf related files state")
        return PDFFileUploadOperations().getOperations(localFile: pdfFile, completion: completion)
    }
}

extension UploadJob: VCSCachable {
    public typealias RealmModel = RealmUploadJob
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()

    public func addToCache() {
        UploadJob.realmStorage.addOrUpdate(item: self)
    }

    public func addOrPartialUpdateToCache() {
        if UploadJob.realmStorage.getByIdOfItem(item: self) != nil {
            UploadJob.realmStorage.partialUpdate(item: self)
        } else {
            UploadJob.realmStorage.addOrUpdate(item: self)
        }
    }

    public func partialUpdateToCache() {
        UploadJob.realmStorage.partialUpdate(item: self)
    }
    
    public func removeFromCache() {
        self.localFiles.forEach { $0.removeFromCache() }
        UploadJob.realmStorage.delete(item: self)
    }
}
