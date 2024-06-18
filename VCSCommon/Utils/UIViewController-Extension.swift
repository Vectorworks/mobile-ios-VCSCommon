import Foundation
import SwiftUI
import UIKit
import Toast
import QuickLook

public extension Bundle {
    static let VCSCommon: Bundle = Bundle.module
}

public extension Notification.Name {
    static let VCSSwiftUIShowTabBar = Notification.Name("VCSSwiftUIShowTabBar")
    static let VCSSwiftUIHideTabBar = Notification.Name("VCSSwiftUIHideTabBar")
    static let VCSSwiftUIHidePlusMenu = Notification.Name("VCSSwiftUIHidePlusMenu")
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
    
    func vcsOBJCMakeToast(message: String) {
        self.view.makeToast(message)
    }
    
    func vcsOBJCMakeToast(message: String, duration: TimeInterval) {
        self.view.makeToast(message, duration: duration)
    }
    
    func vcsOBJCMakeTopToast(message: String) {
        self.view.makeToast(message, position: .top)
    }
    
    func vcsOBJCMakeCenterToast(message: String) {
        self.view.makeToast(message, position: .center)
    }
    
    func vcsOBJCMakeBottomToast(message: String) {
        self.view.makeToast(message, position: .bottom)
    }
    
    func vcsOBJCHideAllToasts() {
        self.view.hideAllToasts()
    }
    
    func vcsOBJCMakeCenterToastActivity() {
        self.view.makeToastActivity(.center)
    }
}
