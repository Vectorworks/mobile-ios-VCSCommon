import Foundation

public enum FilenameValidationError: Error, Hashable {
    case empty, containsInvalidCharacters, exists, lengthy, invalidUser
    
    public var localizedErrorText: String {
        switch self {
        case .empty:
            return "Empty Filename".vcsLocalized
        case .containsInvalidCharacters:
            return "Unsupported characters".vcsLocalized
        case .exists:
            return "File with the same name already exists".vcsLocalized
        case .lengthy:
            return "The maximum length is 255 characters.".vcsLocalized
        case .invalidUser:
            return "Invalid User error".vcsLocalized
        }
    }
}

public class FilenameValidator {
    public static func nameError(ownerLogin: String, storage: String, prefix: String) ->
    NameAndError? {
        let name = prefix.lastPathComponent
        if name.isEmpty {
            return NameAndError(name, FilenameValidationError.empty)
        }
        else if name.count > 255 {
            return NameAndError(name, FilenameValidationError.lengthy)
        }
        else if FolderNameValidator.doesAssetNameContainsIllegalSymbols(name) {
            return NameAndError(name, FilenameValidationError.containsInvalidCharacters)
        }
        else if FilenameValidator.doesExist(ownerLogin: ownerLogin, storage: storage, prefix: prefix) {
            return NameAndError(name, FilenameValidationError.exists)
        }
        
        return nil
    }

    static func doesExist(ownerLogin: String, storage: String, prefix: String) -> Bool {
        let predicate = NSPredicate(format: "ownerLogin == %@ && storageType == %@ && prefix == %@", ownerLogin, storage, prefix)
        if VCSFileResponse.realmStorage.getAll(predicate: predicate).first != nil {
            return true
        }
        
        if VCSFolderResponse.realmStorage.getAll(predicate: predicate).first != nil {
            return true
        }
        
        if VCSGenericRealmModelStorage<UploadJobLocalFile.RealmModel>().getAll(predicate: predicate).first != nil {
            return true
        }
        
        return false
    }
}

public struct FolderNameValidator {
    public static func isNewFolderNameError(folderData: VCSFolderResponse, newFolderName: String) -> NameAndError? {
        guard let ownerLogin = VCSUser.savedUser?.login else { return NameAndError(newFolderName, FilenameValidationError.invalidUser) }
        guard newFolderName.isEmpty == false else { return NameAndError(newFolderName, FilenameValidationError.empty) }
        let parentPrefix = folderData.prefix == "/" ? "" : folderData.prefix
        let fullPrefix = parentPrefix.appendingPathComponent(newFolderName).VCSNormalizedURLString()
        let result = FilenameValidator.nameError(ownerLogin: ownerLogin, storage: folderData.storageTypeString, prefix: fullPrefix)
        return result
    }
    
    static func doesAssetNameContainsIllegalSymbols(_ name: String) -> Bool {
        return name.rangeOfCharacter(from: VCSCommonConstants.invalidCharacterSet) != nil
    }
    
    static func validate(_ name: String) -> Result<String, FilenameValidationError> {
        if name.count > 255 {
            return .failure(FilenameValidationError.lengthy)
        } else if doesAssetNameContainsIllegalSymbols(name) {
            return .failure(FilenameValidationError.containsInvalidCharacters)
        }
        return .success(name)
    }
}
