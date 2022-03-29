import Foundation
import UIKit
import Toast

public extension Bundle {
    public static var VCSCommon: Bundle = Bundle.module
}

@objc public extension UIViewController {
    // expected-warning {{'open' modifier conflicts with extension's default access of 'public'}}
    open class func vcsStoryboardID() -> String {return ""}
    open class func vcsStoryboardName() -> String {return "Main"}
    
    //this will crash if vcsStoryboardID and vcsStoryboardName are not overwritten
    open class func storyboardInstance(_ bundle: Bundle) -> UIViewController {
        let storyboard = UIStoryboard(name: self.vcsStoryboardName(), bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: self.vcsStoryboardID())
    }
    
    @objc func vcsOBJCMakeToast(message: String) {
        self.view.makeToast(message)
    }
    
    @objc func vcsOBJCMakeToast(message: String, duration: TimeInterval) {
        self.view.makeToast(message, duration: duration)
    }
    
    @objc func vcsOBJCMakeTopToast(message: String) {
        self.view.makeToast(message, position: .top)
    }
    
    @objc func vcsOBJCMakeCenterToast(message: String) {
        self.view.makeToast(message, position: .center)
    }
    
    @objc func vcsOBJCMakeBottomToast(message: String) {
        self.view.makeToast(message, position: .bottom)
    }
    
    @objc func vcsOBJCHideAllToasts() {
        self.view.hideAllToasts()
    }
    
    @objc func vcsOBJCMakeCenterToastActivity() {
        self.view.makeToastActivity(.center)
    }
}
