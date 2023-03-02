import SwiftUI
import CocoaLumberjackSwift

public struct NewFolderAlert: ViewModifier {
    @Binding var isPresented: Bool
    @State var currentFolder: VCSFolderResponse?
    @State var folderName = ""
    @State private var showAlertError = false
    @State private var newFolderMessage = ""
    @State var onSuccess: ((VCSFolderResponse) -> Void)?
    @State var onFailure: ((Error) -> Void)?
    @State var isCreateButtonDisabled = false
    
    var nameValidator = VCSAlertTextFieldValidator.defaultWithMessage("")
    
    public func body(content: Content) -> some View {
        content
            .alert(FolderChooserSettings.couldNotCreateFolderAlertTitle.vcsLocalized, isPresented: $showAlertError, actions: {
                Button(FolderChooserSettings.OKButtonTitle.vcsLocalized, role: .cancel, action: {})
            }, message: {
                Text(newFolderMessage)
            })
            .customAlert(isPresented: $isPresented, title: FolderChooserSettings.folderNameTitle.vcsLocalized, message: $newFolderMessage, textFieldName: FolderChooserSettings.newFolderButtonTitle.vcsLocalized, textFieldValue: $folderName, leftButtonName: FolderChooserSettings.folderNameTitle.vcsLocalized, leftButtonAction: {
                self.isPresented = false
                guard let currentFolder = currentFolder ?? FolderChooser.currentFolderRouteData?.folderResponse else { return }
                APIClient.createFolder(storage: currentFolder.storageType, name: folderName, parentFolderPrefix: currentFolder.prefix, owner: currentFolder.ownerLogin).execute(onSuccess: { (result: VCSFolderResponse) in
                    VCSCache.addToCache(item: result)
                    folderName = ""
                    newFolderMessage = ""
                    onSuccess?(result)
                }, onFailure: { (error: Error) in
                    DDLogError("APIClient.createFolder(storage: currentFolder.storageType - \(error)")
                    newFolderMessage = FolderChooserSettings.invalidNameMessage.vcsLocalized
                    if error.responseCode == 409 {
                        newFolderMessage = FolderChooserSettings.folderWithTheSameName___Message.vcsLocalized
                    }
                    showAlertError = true
                    onFailure?(error)
                })
            }, rightButtonName: FolderChooserSettings.cancelButtonTitle.vcsLocalized) {
                self.isPresented = false
            }
    }
}

public extension View {
    func alertNewFolder(isPresented: Binding<Bool>, currentFolder: VCSFolderResponse?, folderName: String = "", onSuccess: ((VCSFolderResponse) -> Void)? = nil, onFailure: ((Error) -> Void)? = nil) -> some View {
        modifier(NewFolderAlert(isPresented: isPresented, currentFolder: currentFolder, folderName: folderName, onSuccess: onSuccess, onFailure: onFailure))
    }
}
