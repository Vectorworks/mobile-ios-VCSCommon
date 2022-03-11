import Foundation
import SystemConfiguration

@objc public class VCSReachability: NSObject {
    private(set) public var reachability: Reachability?
    public static var `default`: VCSReachability = VCSReachability(hostName: "google.com")
    @objc
    public static var defaultOBJC: VCSReachability { return VCSReachability.default }
    
    private var isNotifierRunning: Bool = false
    public var isNotifierSetupAndRunning: Bool { return self.isNotifierRunning }
    
    public init(hostName: String) {
        self.reachability = try? Reachability(hostname: hostName)
        super.init()
        
        self.reachability?.whenReachable = { (reachability: Reachability) in
            self.isNotifierRunning = true
            self.whenReachableArr.forEach { (arg0) in
                let (_, reachable) = arg0
                reachable(reachability)
            }
        }
        
        self.reachability?.whenUnreachable = { (reachability: Reachability) in
            self.isNotifierRunning = true
            self.whenUnreachableArr.forEach { (arg0) in
                let (_, unreachable) = arg0
                unreachable(reachability)
            }
        }
        
        self.startNotifier()
    }
    
    private var whenReachableArr: [AnyHashable: Reachability.NetworkReachable] = [:]
    private var whenUnreachableArr: [AnyHashable: Reachability.NetworkUnreachable] = [:]
    
    public var netStatus: Reachability.Connection {
        get {
            return self.reachability?.connection ?? .unavailable
        }
    }
    
    private func startNotifier() {
        do {
            try self.reachability?.startNotifier()
        } catch {
            print("VCSReachability startNotifier failed")
        }
    }
    
    public func setWhenReachable(_ reachable: Reachability.NetworkReachable?, forKey key: AnyHashable, shouldExecuteInitially: Bool = false) {
        self.whenReachableArr[key] = reachable
        
        if shouldExecuteInitially, let reachability = self.reachability, reachability.connection != .unavailable {
            reachable?(reachability)
        }
    }
    
    public func setWhenUnreachable(_ unreachable: Reachability.NetworkUnreachable?, forKey key: AnyHashable, shouldExecuteInitially: Bool = false) {
        self.whenUnreachableArr[key] = unreachable
        
        if shouldExecuteInitially, let reachability = self.reachability, reachability.connection == .unavailable {
            unreachable?(reachability)
        }
    }
}
