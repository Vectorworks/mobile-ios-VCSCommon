import Foundation

public class VCSUploadDataResponse: NSObject {
    public let uploadDate: Date
    public let googleDriveID: String?
    public let googleDriveVerID: String?
    
    public init(_ date: Date, googleDriveID: String?, googleDriveVerID: String?) {
        self.uploadDate = date
        self.googleDriveID = googleDriveID
        self.googleDriveVerID = googleDriveVerID
    }
}
