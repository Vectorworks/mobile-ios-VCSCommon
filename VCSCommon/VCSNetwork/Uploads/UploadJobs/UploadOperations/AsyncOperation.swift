import Foundation

public class AsyncOperation: Operation {
    private let stateQueue = DispatchQueue (label: "AsyncOperationState", attributes: .concurrent)
    private var _state = State.ready
    public var state: State
    {
        get { stateQueue.sync { return _state } }
        set {
            let oldValue = state
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
            stateQueue.sync(flags: .barrier) {
                _state = newValue
            }
            didChangeValue (forKey: state.keyPath)
            didChangeValue (forKey: oldValue.keyPath)
        }
    }
    
    public override var isReady: Bool {
        guard dependencies.allSatisfy({ $0.isFinished || $0.isCancelled }) else { return false }
        return state == .ready
    }
    
    public override var isFinished: Bool {
        state == .finished
    }
    
    public override var isExecuting: Bool {
        state == .executing
    }
    
    public override var isAsynchronous: Bool {
        return true
    }
    
    public override func start() {
        if isCancelled {
            state = .finished
            return
        }
        state = .executing
        main()
    }
    
    public override func cancel() {
        state = .finished
    }
}

public extension AsyncOperation {
    enum State: String
    {
        case ready
        case executing
        case finished
        
        var keyPath: String {
            "is\(rawValue.capitalized)"
        }
    }
}
