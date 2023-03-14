import SwiftUI

public typealias UploadConfirmationResult = (folder: VCSFolderResponse, name: String)

public class UploadConfirmationViewModel: ObservableObject {
    var isPresented: Binding<Bool>
    var isUFCPresented: Binding<Bool>
    
    var title: String
    var message: String
    var changeFolderButtonName: String
    var uploadButtonName: String
    var uploadButtonAction: ((UploadConfirmationResult) -> Void)?
    
    var isChangeNameEnabled: Bool
    var isNFAPresented: Binding<Bool>
    
    var changeNameButtonName: String
    var fileNameTitle: String
    var fileNameFieldTitle: String
    var fileNameButtonName: String
//    var fileNameMessage: String
    
    var cancelButtonName: String
    var cancelButtonAction: (() -> Void)?
    
    init(isPresented: Binding<Bool>,
         isUFCPresented: Binding<Bool>,
         title: String,
         message: String,
         changeFolderButtonName: String,
         uploadButtonName: String,
         uploadButtonAction: ((UploadConfirmationResult) -> Void)? = nil,
         isChangeNameEnabled: Bool,
         isNFAPresented: Binding<Bool>,
         changeNameButtonName: String,
         fileNameTitle: String,
         fileNameFieldTitle: String,
         fileNameButtonName: String,
//         fileNameMessage: String,
         cancelButtonName: String,
         cancelButtonAction: (() -> Void)? = nil) {
        self.isPresented = isPresented
        self.isUFCPresented = isUFCPresented
        self.title = title
        self.message = message
        self.changeFolderButtonName = changeFolderButtonName
        self.uploadButtonName = uploadButtonName
        self.uploadButtonAction = uploadButtonAction
        self.isChangeNameEnabled = isChangeNameEnabled
        self.isNFAPresented = isNFAPresented
        self.changeNameButtonName = changeNameButtonName
        self.fileNameTitle = fileNameTitle
        self.fileNameFieldTitle = fileNameFieldTitle
        self.fileNameButtonName = fileNameButtonName
//        self.fileNameMessage = fileNameMessage
        self.cancelButtonName = cancelButtonName
        self.cancelButtonAction = cancelButtonAction
    }
}

public struct UploadConfirmation: ViewModifier {
    @ObservedObject var model: UploadConfirmationViewModel
    @State var newFileName: String = FileNameUtils.appendingTimeStampToName(name: "Nomad")
    @State var uploadFolder: VCSFolderResponse
    @State private var newFolderMessage = ""
    @State private var tempFileName = ""
    
    var generatedMessage: String {
        var result = self.model.message + "\n" + "\(self.uploadFolder.displayedPrefix)"
        if self.model.isChangeNameEnabled {
            result = result + "\n" + "With the following name:".vcsLocalized + "\n" + self.newFileName
        }
        
        return result
    }
    
    public func body(content: Content) -> some View {
        content
            .confirmationDialog(model.title, isPresented: model.isPresented, actions: {
                Button {
                    model.isUFCPresented.wrappedValue = true
                } label: {
                    Text(model.changeFolderButtonName)
                }
                if model.isChangeNameEnabled {
                    Button {
                        self.tempFileName = self.newFileName
                        model.isNFAPresented.wrappedValue = true
                    } label: {
                        Text(model.changeNameButtonName)
                    }
                }
                Button {
                    model.uploadButtonAction?(UploadConfirmationResult(folder: uploadFolder, name: newFileName))
                } label: {
                    Text(model.uploadButtonName)
                }
                if model.cancelButtonName.isEmpty == false {
                    Button(role: .cancel, action: {
                        model.cancelButtonAction?()
                    }, label: {
                        Text(model.cancelButtonName)
                    })
                }
            }, message: {
                if model.message.isEmpty == false {
                    Text(self.generatedMessage)
                }
            })
            .fullScreenCover(isPresented: model.isUFCPresented, content: {
                FolderChooser(routeData: FCRouteData(folder: self.uploadFolder), folderResult: self.$uploadFolder, isPresented: model.isUFCPresented, parentIsPresented: model.isPresented)
            })
            .customAlert(isPresented: model.isNFAPresented, title: model.fileNameTitle, message: $newFolderMessage, textFieldName: model.fileNameFieldTitle, textFieldValue: self.$newFileName, leftButtonName: model.fileNameButtonName, leftButtonAction: {
                model.isNFAPresented.wrappedValue = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    model.isPresented.wrappedValue = true
                }
            }, rightButtonName: FolderChooserSettings.cancelButtonTitle.vcsLocalized) {
                model.isNFAPresented.wrappedValue = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.newFileName = self.tempFileName
                    model.isPresented.wrappedValue = true
                }
            }
    }
}

public extension View {
    func uploadConfirmationDialog(isPresented: Binding<Bool>,
                                  isUFCPresented: Binding<Bool>,
                                  uploadFolder: VCSFolderResponse,
                                  title: String = "",
                                  message: String = "The files will be uploaded to:".vcsLocalized,
                                  changeButtonName: String = "Change folder".vcsLocalized,
                                  uploadButtonName: String = "Start upload".vcsLocalized,
                                  uploadButtonAction: ((UploadConfirmationResult) -> Void)?,
                                  isChangeNameEnabled: Bool = false,
                                  isNFAPresented: Binding<Bool> = .constant(false),
                                  changeNameButtonName: String = "Change file name".vcsLocalized,
                                  fileNameTitle: String = "Enter File Name".vcsLocalized,
                                  fileNameFieldTitle: String = "File name".vcsLocalized,
                                  fileNameButtonName: String = "Save file name".vcsLocalized,
//                                  fileNameMessage: String = "",
                                  cancelButtonName: String = "",
                                  cancelButtonAction: (() -> Void)? = nil) -> some View {
        modifier(UploadConfirmation(model: UploadConfirmationViewModel(isPresented: isPresented,
                                                                       isUFCPresented: isUFCPresented,
                                                                       title: title,
                                                                       message: message,
                                                                       changeFolderButtonName: changeButtonName,
                                                                       uploadButtonName: uploadButtonName,
                                                                       uploadButtonAction: uploadButtonAction,
                                                                       isChangeNameEnabled: isChangeNameEnabled,
                                                                       isNFAPresented: isNFAPresented,
                                                                       changeNameButtonName: changeNameButtonName,
                                                                       fileNameTitle: fileNameTitle,
                                                                       fileNameFieldTitle: fileNameFieldTitle,
                                                                       fileNameButtonName: fileNameButtonName,
//                                                                       fileNameMessage: fileNameMessage,
                                                                       cancelButtonName: cancelButtonName,
                                                                       cancelButtonAction: cancelButtonAction),
                                    uploadFolder: uploadFolder))
    }
}
