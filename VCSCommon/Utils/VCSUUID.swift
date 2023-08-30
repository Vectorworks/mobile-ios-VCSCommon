import Foundation

public class VCSUUID {
    public private(set) var systemUUID: UUID
    
    public init() {
        systemUUID = UUID()
    }
    
    public init?(uuidString string: String) {
        guard let newUUID = UUID(uuidString: string) else { return nil }
        systemUUID = newUUID
    }
    
    public func shortenString() -> String {
        let uuidString = systemUUID.uuidString
        guard let index = uuidString.lastIndex(of: "-") else { return uuidString }
        return String(uuidString.suffix(from: index).dropFirst())
    }
}
