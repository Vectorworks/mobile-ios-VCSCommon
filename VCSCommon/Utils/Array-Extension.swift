import Foundation
import CocoaLumberjackSwift

public extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {
            DDLogError("Array Extension remove - index not found")
            return
        }
        remove(at: index)
    }
}
