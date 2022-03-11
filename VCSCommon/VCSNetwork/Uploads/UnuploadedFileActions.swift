import Foundation

public class UnuploadedFileActions {
    
    public static func saveUnuploadedFiles(_ files: [UnuploadedFile]) {
        files.forEach { UnuploadedFileActions.saveUnuploadedFile($0) }
    }
    
    private static func saveUnuploadedFile(_ file: UnuploadedFile) {
        defer { NotificationCenter.postNotification(name: Notification.Name("VCSUpdateDataSources"), userInfo: nil) }
        
        UnuploadedFileActions.saveUnuploadedFileToRealm(file.metadata)
        
        file.related.forEach { (relatedFile) in
            UnuploadedFileActions.saveUnuploadedFileToRealm(relatedFile.metadata)
        }
    }
    
    private static func saveUnuploadedFileToRealm(_ file: VCSCachable) {
        VCSCache.addToCache(item: file)
    }
    
    public static func deleteUnuploadedFiles(_ files: [LocalFileForUpload]) {
        files.forEach { UnuploadedFileActions.deleteUnuploadedFile($0) }
    }
    
    static private func deleteUnuploadedFile(_ file: LocalFileForUpload) { // after successful upload
        guard file.isAvailableOnDevice else { return }
        
        file.removeFromCache()
        try? FileUtils.deleteItem(file.localPath)
        
        file.related.forEach { UnuploadedFileActions.deleteUnuploadedFile($0) }
    }
}
