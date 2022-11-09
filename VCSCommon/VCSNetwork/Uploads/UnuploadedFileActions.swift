import Foundation

public class UnuploadedFileActions {
    
    public static func saveUnuploadedFiles(_ files: [UploadJobLocalFile]) {
        files.forEach { UnuploadedFileActions.saveUnuploadedFile($0) }
    }
    
    private static func saveUnuploadedFile(_ file: UploadJobLocalFile) {
        defer { NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil) }
        
        UnuploadedFileActions.saveUnuploadedFileToRealm(file)
        
        file.related.forEach { (relatedFile) in
            UnuploadedFileActions.saveUnuploadedFileToRealm(relatedFile)
        }
    }
    
    private static func saveUnuploadedFileToRealm(_ file: VCSCachable) {
        VCSCache.addToCache(item: file)
    }
    
    public static func deleteUnuploadedFiles(_ files: [UploadJobLocalFile]) {
        files.forEach { UnuploadedFileActions.deleteUnuploadedFile($0) }
    }
    
    static private func deleteUnuploadedFile(_ file: UploadJobLocalFile) { // after successful upload
        guard file.isAvailableOnDevice else { return }
        
        file.removeFromCache()
        try? FileUtils.deleteItem(file.uploadPathURL.path)
        
        file.related.forEach { UnuploadedFileActions.deleteUnuploadedFile($0) }
    }
}
