import Foundation

@objc public class PDFFileAsset: NSObject {
    public let fileAsset: FileAsset
    
    init(fileAsset: FileAsset) {
        self.fileAsset = fileAsset
    }
    
    @objc var name: String { return self.fileAsset.name }
    @objc var ownerLogin: String { return self.fileAsset.ownerLogin }
    @objc var storageTypeString: String { return self.fileAsset.storageTypeString }
    @objc var prefix: String { return self.fileAsset.prefix }
}
