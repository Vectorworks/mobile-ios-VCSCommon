import Foundation

@objc public class VCSUploadDataResponse: NSObject {
    @objc public let uploadDate: Date
    @objc public let googleDriveID: String?
    @objc public let googleDriveVerID: String?
    
    public init(_ date: Date, googleDriveID: String?, googleDriveVerID: String?) {
        self.uploadDate = date
        self.googleDriveID = googleDriveID
        self.googleDriveVerID = googleDriveVerID
    }
}
