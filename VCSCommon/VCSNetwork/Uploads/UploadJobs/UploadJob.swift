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
    public var localFiles: [UploadJobLocalFile]
    public let parentFolder: VCSFolderResponse?
    
    public init(jobID: String = UUID().uuidString, jobOperation: JobType = .MultipleFileUpload, localFiles: [UploadJobLocalFile], parentFolder: VCSFolderResponse?) {
        self.jobID = jobID
        self.jobOperation = jobOperation
        self.localFiles = localFiles
        self.parentFolder = parentFolder
        super.init()
        if UploadJob.uploadJobs.contains(where: { $0.jobID == self.jobID }) == false {
            UploadJob.uploadJobs.append(self)
        }
    }
    
    public convenience init(jobID: String = UUID().uuidString, jobOperation: JobType = .SingleFileUpload, localFile: UploadJobLocalFile, parentFolder: VCSFolderResponse?) {
        self.init(jobID: jobID, jobOperation: jobOperation, localFiles: [localFile], parentFolder: parentFolder)
    }
    
    func reCheckState(localFile: UploadJobLocalFile) {
        DDLogInfo("UploadJob:reCheckState - \(self.localFiles.filter({ $0.uploadingState == .Done }).count) of \(self.localFiles.count)")
        self.localFiles.removeAll { $0.rID == localFile.rID }
        VCSCache.addToCache(item: self)
        UploadJob.deleteUnuploadedFile(localFile)
        guard self.localFiles.allSatisfy({ $0.uploadingState == .Done }) else { return }
        self.removeFromCache()
        NotificationCenter.postNotification(name: Notification.Name("VCSUpdateLocalDataSources"), userInfo: nil)
    }
}

public extension UploadJob {
    func startUploadOperations(singleFileCompletion: ((Result<VCSFileResponse, Error>) -> Void)? = nil, multiFileCompletion: ((Result<[VCSFileResponse], Error>) -> Void)? = nil) {
        var operations: [Operation] = []
        switch self.jobOperation {
        case .SingleFileUpload:
            operations = getSimpleFileUpload(completion: singleFileCompletion)
        case .MultipleFileUpload:
            operations = getMultipleFileUpload(completion: multiFileCompletion)
        case .PDFFileUpload:
            operations = getPDFFileUpload(completion: singleFileCompletion)
        }
        
        VCSBackgroundSession.default.operationQueue.addOperations(operations, waitUntilFinished: false)
        NotificationCenter.postNotification(name: Notification.Name("VCSUpdateLocalDataSources"), userInfo: nil)
    }
    
    private func getSimpleFileUpload(completion: ((Result<VCSFileResponse, Error>) -> Void)? = nil) -> [Operation] {
        guard let singleFile = self.localFiles.first, singleFile.uploadingState != .Done else { return [] }
        return SimpleFileUploadOperations().getOperations(localFile: singleFile, completion: completion)
    }
    
    private func getMultipleFileUpload(completion: ((Result<[VCSFileResponse], Error>) -> Void)? = nil) -> [Operation] {
        let localFiles = self.localFiles.filter { $0.uploadingState != .Done }
        return SimpleFileMultipleUploadsOperations().getOperations(localFiles: localFiles, completion: completion)
    }
    
    private func getPDFFileUpload(completion: ((Result<VCSFileResponse, Error>) -> Void)? = nil) -> [Operation] {
        guard let pdfFile = self.localFiles.first, (pdfFile.uploadingState != .Done || pdfFile.related.contains(where: { $0.uploadingState != .Done })) else { return [] }
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
        UploadJob.deleteUnuploadedFiles(self.localFiles)
//        self.localFiles.forEach { $0.removeFromCache() }
        UploadJob.realmStorage.delete(item: self)
    }
}

extension UploadJob {
    public static func deleteUnuploadedFiles(_ files: [UploadJobLocalFile]) {
        files.forEach { UploadJob.deleteUnuploadedFile($0) }
    }
    
    static private func deleteUnuploadedFile(_ file: UploadJobLocalFile) { // after successful upload
        guard file.isAvailableOnDevice else { return }
        
        file.removeFromCache()
        do {
            try FileUtils.deleteItem(file.uploadPathURL.path)
        } catch {
            DDLogError("UnuploadedFileActions deleteUnuploadedFile(_ file:" + error.localizedDescription)
        }
        
        file.related.forEach { UploadJob.deleteUnuploadedFile($0) }
    }
}
