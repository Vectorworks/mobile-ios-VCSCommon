import Foundation

@objc public class UnuploadedFile: NSObject {
    public let metadata: LocalFileForUpload
    public let related: [UnuploadedFile]
    
    public init(metadata: LocalFileForUpload, tempFileURL: URL, related: [UnuploadedFile]) {
        self.metadata = metadata
        if tempFileURL.path != metadata.localPathURL.path {
            try? FileUtils.moveItem(at: tempFileURL, to: metadata.localPathURL)
        }
        self.related = related
    }
}
