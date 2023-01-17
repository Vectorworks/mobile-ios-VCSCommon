import Foundation
import Network
import CocoaLumberjackSwift

@objc public class VCSReachability: NSObject {
    public static var `default`: VCSReachability = VCSReachability(startMonitoring: false)
//    @objc
//    public static var defaultOBJC: VCSReachability { return VCSReachability.default }
    
    @Published public private(set) var isConnected = true
    @Published public private(set) var isCellular = false
    
    private let nwMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue.global()
    
    public func start() {
        guard nwMonitor.queue == nil else {
            DDLogError("Starting VCSReachability NWPathMonitor again.")
            return
        }
        nwMonitor.start(queue: workerQueue)
        nwMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                guard let self else { return }
                let newIsConnected = path.status == .satisfied
                if self.isConnected != newIsConnected {
                    self.isConnected = newIsConnected
                }
                let newIsCellular = path.usesInterfaceType(.cellular)
                if self.isCellular != newIsCellular {
                    self.isCellular = newIsCellular
                }
            }
        }
    }
    
    public func stop() {
        nwMonitor.cancel()
    }
    
    private var isNotifierRunning: Bool = false
    public var isNotifierSetupAndRunning: Bool { return self.isNotifierRunning }
    
    public init(startMonitoring: Bool = true) {
        super.init()
        if startMonitoring {
            self.start()
        }
    }
}
