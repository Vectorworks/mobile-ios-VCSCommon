import Foundation
import UIKit

@objc class VCSFCIconsStr: NSObject {
    @objc public static let badge_view = "badge-view"
    @objc public static let badge_download = "badge-download"
    @objc public static let badge_edit = "badge-edit"
}

extension String {
    var namedImage: UIImage? {
        return UIImage(named: self, in: Bundle(for: VCSFCIconsStr.self), compatibleWith: nil)
    }
}

extension UIImage {
    var template: UIImage? {
        return self.withRenderingMode(.alwaysTemplate)
    }
}

