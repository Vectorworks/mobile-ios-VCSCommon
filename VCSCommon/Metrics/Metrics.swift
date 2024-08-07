import UIKit
import CocoaLumberjackSwift
import FirebaseAnalytics

let kVCSMetricsNotification            = "kVCSMetricsNotification"
let kVCSMetricsNotification_event      = "kVCSMetricsNotification_event"
let kVCSMetricsNotification_params     = "kVCSMetricsNotification_params"

public class Metrics {
    public static let `default` = Metrics()
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(notification:)), name: .VCSMetricsNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleNotification(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let event = userInfo[kVCSMetricsNotification_event] as? String else {
            DDLogError("Received metrics notification, but userInfo is nil.")
            return
        }
        
        let params = userInfo[kVCSMetricsNotification_params] as? [String : Any]
        self.logEvent(event, parameters: params)
    }
    
    public func logEvent(_ event: String, parameters: [String : Any]? = nil) {
        var paramString = ""
        if let params = parameters {
            paramString = ": \(params)"
        }
        let logString = event + paramString
        DDLogInfo("\(event + paramString)")
        Analytics.logEvent(event, parameters: parameters)
    }
}

public extension Notification.Name {
    static let VCSMetricsNotification = Notification.Name(kVCSMetricsNotification)
}
