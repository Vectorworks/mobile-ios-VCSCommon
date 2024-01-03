import Foundation
import CocoaLumberjackSwift

public class DeviceShareUtils {
    public static func deviceShare(shareFilesURLs: [URL], sourceView: UIView, presenter: UIViewController, completion: (() -> Void)? = nil) {
        guard shareFilesURLs.count > 0 else {
            completion?()
            return
        }
        
        let shareActivity = UIActivityViewController(activityItems: shareFilesURLs, applicationActivities: nil)
        shareActivity.popoverPresentationController?.sourceView = sourceView
        if UIDevice.current.userInterfaceIdiom == .pad {
            shareActivity.popoverPresentationController?.permittedArrowDirections = .any
        }
        presenter.present(shareActivity, animated: true, completion: completion)
    }
    
    public static func copyURLsWithNames(localFileNameAndPaths: [LocalFileNameAndPath]) -> [URL] {
        let tempShareFilesAndURLs:[(String, URL)] = localFileNameAndPaths.compactMap {
            return ($0.itemName, $0.itemURL)
        }
        
        let shareFilesURLs:[URL] = DeviceShareUtils.copyURLsWithNames(tempFileNameURL: tempShareFilesAndURLs)
        return shareFilesURLs
    }
    
    public static func copyURLsWithNames(cellDataHolders: [VCSCellDataHolder]) -> [URL] {
        let tempShareFilesAndURLs:[(String, URL)] = cellDataHolders.compactMap {
            guard let fileAsset = ($0.assetData as? FileAsset), let localPathString = fileAsset.localPathString else { return nil }
            return (fileAsset.name, URL(fileURLWithPath: localPathString))
        }
        
        let shareFilesURLs:[URL] = DeviceShareUtils.copyURLsWithNames(tempFileNameURL: tempShareFilesAndURLs)
        return shareFilesURLs
    }
    
    public static func copyURLsWithNames(fileAssets: [FileAsset]) -> [URL] {
        let tempShareFilesAndURLs:[(String, URL)] = fileAssets.compactMap {
            guard let localPathString = $0.localPathString else { return nil }
            return ($0.name, URL(fileURLWithPath: localPathString))
        }
        
        let shareFilesURLs:[URL] = DeviceShareUtils.copyURLsWithNames(tempFileNameURL: tempShareFilesAndURLs)
        return shareFilesURLs
    }
    
    private static func copyURLsWithNames(tempFileNameURL: [(String, URL)]) -> [URL] {
        var shareFilesURLs:[URL] = []
        try? FileManager.default.removeItem(at: FileManager.AppShareExtDirectory)
        tempFileNameURL.forEach {
            let shareFileURL = FileManager.AppShareExtDirectory.appendingPathComponent($0.0)
            do {
                try FileUtils.copyFile(at: $0.1, to: shareFileURL)
                shareFilesURLs.append(shareFileURL)
            } catch {
                DDLogError("Error while coping file: \(error)")
            }
        }
        
        return shareFilesURLs
    }
}
