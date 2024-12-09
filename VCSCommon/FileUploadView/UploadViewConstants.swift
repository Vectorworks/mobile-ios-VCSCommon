import SwiftUI

class UploadViewConstants {
    static let lastSelectedImportUploadFolderIDKey = "UploadViewFileImport-lastProjectFolderID"
    static let lastSelectedRealityCaptureUploadFolderIDKey = "UploadViewRealityCapture-lastProjectFolderID2"
}

struct FileUploadURLParams {
    var ownerLogin: String
    var storageTypeString: String
    var storageType: StorageType
    var parentFolderPrefix: String
    
    init?(folder: VCSFolderResponse?) {
        guard let folder else { return nil }
        self.ownerLogin = folder.ownerLogin
        self.storageTypeString = folder.storageTypeString
        self.storageType = folder.storageType
        self.parentFolderPrefix = folder.prefix
    }
}
