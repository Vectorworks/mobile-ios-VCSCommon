import Foundation

public enum VCSError: Error, Equatable {
    case IllegalArgumentException(String)
    case GenericException(String)
    case UserCancelled
    case CapturedRoomIsNil
    case OperationNotExecuted
    case LocalFileNotCreated
}
