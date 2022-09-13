import Foundation

public enum VCSError: Error {
    case IllegalArgumentException(String)
    case GenericException(String)
    case UserCancelled
    case CapturedRoomIsNil
}
