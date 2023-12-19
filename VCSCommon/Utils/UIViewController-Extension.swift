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

@objc open class VCSToggleSwiftUITabBarVC: UIViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        if self.hidesBottomBarWhenPushed == true {
            NotificationCenter.default.post(name: .VCSSwiftUIHideTabBar, object: nil)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.hidesBottomBarWhenPushed == true {
            NotificationCenter.default.post(name: .VCSSwiftUIShowTabBar, object: nil)
        }
    }
}

open class VCSToggleSwiftUITabBarQLVC : QLPreviewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        if self.hidesBottomBarWhenPushed == true {
            NotificationCenter.default.post(name: .VCSSwiftUIHideTabBar, object: nil)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.hidesBottomBarWhenPushed == true {
            NotificationCenter.default.post(name: .VCSSwiftUIShowTabBar, object: nil)
        }
    }
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
