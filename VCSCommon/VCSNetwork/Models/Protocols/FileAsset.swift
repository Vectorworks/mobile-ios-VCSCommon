import Foundation

@objc public protocol FileAsset: Asset {
    var downloadURLString: String { get }
    var isAvailableOnDevice: Bool { get }
    var localPathString: String? { get }
    var fileTypeString: String? { get }
    var relatedFileAssets: [FileAsset] { get }
}

extension FileAsset {
    public func related(withExtension ext: VCSFileType) -> FileAsset? {
        return self.relatedFileAssets.filter({ (file) -> Bool in
            return ext.isInFileName(name: file.name)
        }).first
    }
}
