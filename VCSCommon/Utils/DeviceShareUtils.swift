import Foundation
import UIKit

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
}
