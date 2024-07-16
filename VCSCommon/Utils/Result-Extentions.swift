import Foundation

public extension Result {
    var isSuccess: Bool { if case .success = self { return true } else { return false } }

    var isError: Bool {  return !isSuccess  }
}
