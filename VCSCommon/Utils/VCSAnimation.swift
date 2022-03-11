import Foundation
import UIKit

@objc public class VCSAnimation:NSObject {
    static public func animateFlashEffect(on view:UIView) {
        let v = UIView(frame: view.bounds)
        v.backgroundColor = UIColor.white
        v.alpha = 1
        
        view.addSubview(v)
        UIView.animate(withDuration: 0.5, animations: {
            v.alpha = 0.0
        }, completion: {(finished:Bool) in
            v.removeFromSuperview()
        })
    }
}
