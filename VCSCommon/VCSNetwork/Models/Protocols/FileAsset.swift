import Foundation

@objc public protocol FileAsset: Asset {
    @objc var downloadURLString: String { get }
    @objc var isAvailableOnDevice: Bool { get }
    @objc var localPathString: String? { get }
    @objc var fileTypeString: String? { get }
    @objc var relatedFileAssets: [FileAsset] { get }
}

extension FileAsset {
    public func related(withExtension ext: VCSFileType) -> FileAsset? {
        return self.relatedFileAssets.filter({ (file) -> Bool in
            return ext.isInFileName(name: file.name)
        }).first
    }
}
