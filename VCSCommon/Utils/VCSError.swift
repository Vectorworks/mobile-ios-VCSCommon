import Foundation

public enum VCSError: Error, Equatable {
    case noInitialData
    case IllegalArgumentException(String)
    case GenericException(String)
    case UserCancelled
    case CapturedRoomIsNil
    case OperationNotExecuted(String)
    case LocalFileNotCreated
}

extension VCSError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noInitialData:
            return "no Initial Data"
        case .IllegalArgumentException(let value):
            return "IllegalArgumentException - \(value)"
        case .GenericException(let value):
            return "GenericException - \(value)"
        case .UserCancelled:
            return "UserCancelled"
        case .CapturedRoomIsNil:
            return "CapturedRoomIsNil"
        case .OperationNotExecuted(let value):
            return "OperationNotExecuted - \(value)"
        case .LocalFileNotCreated:
            return "LocalFileNotCreated"
        }
    }
}
