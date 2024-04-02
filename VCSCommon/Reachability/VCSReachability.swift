import Foundation
import Network
import CocoaLumberjackSwift

public class VCSReachability: ObservableObject {
    public static var `default`: VCSReachability = VCSReachability(startMonitoring: false)
    
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
                self?.isConnected = (path.status == .satisfied)
                self?.isCellular = path.usesInterfaceType(.cellular)
            }
        }
    }
    
    public func stop() {
        nwMonitor.cancel()
    }
    
    private var isNotifierRunning: Bool = false
    public var isNotifierSetupAndRunning: Bool { return self.isNotifierRunning }
    
    public init(startMonitoring: Bool = true) {
        if startMonitoring {
            self.start()
        }
    }
}
