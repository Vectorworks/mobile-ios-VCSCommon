import Foundation
import CoreGraphics
import CommonCrypto


public class EmailAvatar {
    public static func imageUrl(email: String, size: CGSize) -> URL? {
        let emailHex = email.lowercased().MD5Hex
        let gravatar_url = "https://www.gravatar.com/avatar/\(emailHex)?s=\(size.height)&d=404"
        
        return URL(string: gravatar_url)
    }
}
