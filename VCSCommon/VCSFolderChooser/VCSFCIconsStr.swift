import Foundation
import UIKit

class VCSFCIconsStr: NSObject {
    public static let badge_view = "badge-view"
    public static let badge_download = "badge-download"
    public static let badge_edit = "badge-edit"
}

extension String {
    var namedImage: UIImage? {
        return UIImage(named: self, in: Bundle.module, compatibleWith: nil)
    }
}

extension UIImage {
    var template: UIImage? {
        return self.withRenderingMode(.alwaysTemplate)
    }
}

