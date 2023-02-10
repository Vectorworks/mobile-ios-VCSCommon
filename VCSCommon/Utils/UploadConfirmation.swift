import SwiftUI

public struct UploadConfirmation: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var uploadFolder: VCSFolderResponse
    @State var title: String
    @State var message: String
    @State var changeButtonName: String
    @State var uploadButtonName: String
    @State var uploadButtonAction: (() -> Void)?
    
    @State private var showFolderChooser = false
    
    public func body(content: Content) -> some View {
        content
            .confirmationDialog(title, isPresented: $isPresented, actions: {
                Button {
                    showFolderChooser.toggle()
                } label: {
                    Text(changeButtonName)
                }
                Button {
                    uploadButtonAction?()
                } label: {
                    Text(uploadButtonName)
                }
            }, message: {
                if message.isEmpty == false {
                    Text(message + "\n\(uploadFolder.displayedPrefix)")
                }
            })
            .fullScreenCover(isPresented: $showFolderChooser, content: {
                FolderChooser(routeData: FCRouteData(folder: uploadFolder), folderResult: $uploadFolder, isPresented: $showFolderChooser, parentIsPresented: $isPresented)
            })
    }
}

public extension View {
    func uploadConfirmationDialog(isPresented: Binding<Bool>, uploadFolder: Binding<VCSFolderResponse>, title: String, message: String, changeButtonName: String, uploadButtonName: String, uploadButtonAction: (() -> Void)?) -> some View {
        modifier(UploadConfirmation(isPresented: isPresented, uploadFolder: uploadFolder, title: title, message: message, changeButtonName: changeButtonName, uploadButtonName: uploadButtonName, uploadButtonAction: uploadButtonAction))
    }
}
