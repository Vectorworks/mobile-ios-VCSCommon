import UIKit
import Foundation

@objc public class VCSAlertTextFieldValidator: NSObject, UITextFieldDelegate {
    public static var privateDefaultInstance: VCSAlertTextFieldValidator = VCSAlertTextFieldValidator()
    public static var `default`: VCSAlertTextFieldValidator { return VCSAlertTextFieldValidator.privateDefaultInstance }
    
    private override init() { }
    
    @objc public static func defaultWithPresenter(_ presenter: UIViewController) -> VCSAlertTextFieldValidator {
        VCSAlertTextFieldValidator.default.presenter = presenter
        VCSAlertTextFieldValidator.default.originalMessage = nil
        return VCSAlertTextFieldValidator.default
    }
    
    private var presenter: UIViewController?
    private var originalMessage: String?
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var result = true
        guard let alert = self.presenter?.presentedViewController as? UIAlertController else { return result }
        if self.originalMessage == nil {
            self.originalMessage = alert.message
        }
        
        var newString = string
        if let textFieldText = textField.text, let swiftRange = Range(range, in: textFieldText) {
            newString = textFieldText.replacingCharacters(in: swiftRange, with: newString)
        }
        
        if newString.count > 255 {
            alert.message = "The maximum length is 255 characters.".vcsLocalized
            result = false
        }
        
        let invalidCharacters = CharacterSet(charactersIn: VCSCommonConstants.invalidCharacterList)
        if newString.rangeOfCharacter(from: invalidCharacters) != nil {
            alert.message = String(format: "%@ %@\n", "The following characters are invalid:".vcsLocalized, String(format: VCSCommonConstants.invalidCharacterListStringFormat, "and".vcsLocalized))
            
            result = false
        }
        if newString.containsEmoji {
            alert.message = "Emojis are not allowed.".vcsLocalized
            result = false
        }
        
        alert.actions.forEach({ (action: UIAlertAction) in
            if action.style != .cancel, action.style != .destructive {
                let remainingText = result ? newString : textField.text ?? ""
                action.isEnabled = remainingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            }
        })
        
        if result {
            alert.message = self.originalMessage
        }
        
        return result
    }
    
}
