import UIKit

class LetterAvatarBuilder: NSObject {

    func makeAvatar(with configuration: LetterAvatarBuilderConfiguration) -> UIImage? {
        return drawAvatar(with: configuration, letters: configuration.letters, backgroundColor: configuration.backgroundColor)
    }
    
    private func drawAvatar(with configuration: LetterAvatarBuilderConfiguration, letters: String, backgroundColor: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: configuration.size.width, height: configuration.size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        let borderWidth = configuration.borderWidth
        let borderColor = configuration.borderColor.cgColor
        let strokeRect = rect.insetBy(dx: borderWidth * 0.5, dy: borderWidth * 0.5)
        context.setFillColor(backgroundColor.cgColor)
        context.setStrokeColor(borderColor)
        context.setLineWidth(borderWidth)
        context.strokeEllipse(in: strokeRect)
        context.fillEllipse(in: rect)
        
        
        let attributes  = [
            NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default,
            NSAttributedString.Key.font: makeFitFont(withFont: nil, forSize: rect.size),
            NSAttributedString.Key.foregroundColor: configuration.lettersColor
        ]
        
        let lettersSize = letters.size(withAttributes: attributes)
        let lettersRect = CGRect(
            x: (rect.size.width - lettersSize.width) / 2.0,
            y: (rect.size.height - lettersSize.height) / 2.0,
            width: lettersSize.width,
            height: lettersSize.height
        )
        letters.draw(in: lettersRect, withAttributes: attributes)
        let avatarImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return avatarImage
    }
    
    private func makeFitFont(withFont font: UIFont?, forSize size: CGSize) -> UIFont {
        guard let font = font else {
            return UIFont.systemFont(ofSize:min(size.height, size.width) / 2.0)
        }
        let fitFont = font.withSize(min(size.height, size.width) / 2.0)
        return fitFont.pointSize < font.pointSize ? fitFont : font
    }
}
