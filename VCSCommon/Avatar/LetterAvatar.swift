import Foundation
import UIKit
import CoreGraphics

public class LetterAvatar {
    public static func avatar(name: String, email: String, login: String, size: CGSize) -> UIImage? {
        let config = LetterAvatarBuilderConfiguration()
        config.name = name
        config.email = email
        config.login = login
        config.size = size
        return LetterAvatarBuilder().makeAvatar(with: config)
    }
}
