import SwiftUI
import SceneKit

public struct FileUploadView: View, KeyboardReadable {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject public var model: FileUploadViewModel
    
    @State var isFolderChooserPresented = false
    @State var isKeyboardVisible = false
    
    @State var projectLocationName = ""
    
    public init(model: FileUploadViewModel, isFolderChooserPresented: Bool = false, isKeyboardVisible: Bool = false) {
        self.model = model
        self.isFolderChooserPresented = isFolderChooserPresented
        self.isKeyboardVisible = isKeyboardVisible
    }
    
    var generatedMessage: String {
        return "Upload Files".vcsLocalized
    }
    
    var areNamesValid: Bool {
        let result = model.areNamesValid(newProjectName: projectLocationName)
        return result.allSatisfy { $0.isSuccess }
    }
    
    var namesValidationError: FilenameValidationError? {
        let result = model.areNamesValid(newProjectName: projectLocationName)
        let error = result.filter({ $0.isError }).first
        switch error {
        case .failure(let failure):
            return failure
        default:
            return nil
        }
    }
    
    public var body: some View {
        if let parentFolderResult = model.rootFolderResult {
            switch parentFolderResult {
            case .success(let modelParentFolder):
                VStack {
                    VStack(spacing: 0) {
                        HStack{
                            Button {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                dismiss()
                            } label: {
                                Text("Discard".vcsLocalized)
                            }
                            .buttonStyle(.realityCaptureVisualEffectRoundedCornerStyle)
                            
                            Spacer()
                            
                            Button {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                model.uploadAction(newProjectName: projectLocationName, dismiss: dismiss)
                            } label: {
                                Text("Upload".vcsLocalized)
                            }
                            .buttonStyle(.realityCaptureVisualEffectRoundedCornerStyle)
                            .disabled(areNamesValid == false || model.isUploading == true)
                        }
                        .padding()
                        
                        if model.isUploading {
                            ProgressView(value: model.totalProgress, total: model.totalUploadsCount)
                            Divider()
                        }
                        
                        ScrollView {
                            VStack {
                                Text("Project Location:")
                                    .font(.subheadline)
                                
                                Picker("", selection: $model.pickerProjectsBrowseOption) {
                                    ForEach(ProjectsBrowseOptions.allCases) { option in
                                        Text(String(describing: option)).tag(option)
                                    }
                                }
                                .pickerStyle(.segmented)
                                
                                Group {
                                    if model.pickerProjectsBrowseOption == .New {
                                        HStack {
                                            Text("Name")
                                                .font(.subheadline)
                                            TextField("Enter project name", text: $projectLocationName)
                                                .textFieldStyle(.roundedBorder)
                                        }
                                        .padding(.top)
                                    } else {
                                        Picker("", selection: model.projectFolderID) {
                                            ForEach(modelParentFolder.subfolders, id: \.rID) { subfolder in
                                                Text(subfolder.name).tag(Optional(subfolder.rID))
                                            }
                                        }
                                        .truncationMode(.tail)
                                    }
                                }
                            }
                            .padding()
                            
                            Divider()
                            
                            VStack {
                                Text("File:")
                                    .font(.subheadline)
                                HStack {
                                    Text("Name")
                                        .font(.subheadline)
                                    VStack{
                                        HStack {
                                            if let firstFile = model.itemsLocalNameAndPath.first {
                                                Image(uiImage: FileUploadView.placeholder(fileExtension: firstFile.itemPathExtension))
                                            }
                                            TextField("Please enter a filename.".vcsLocalized, text: $model.baseFileName)
                                                .onSubmit {
                                                    guard model.baseFileName.count > 0 else { return }
                                                    print(model.baseFileName)
                                                }
                                                .textInputAutocapitalization(.never)
                                                .disableAutocorrection(true)
                                                .submitLabel(.done)
                                                .truncationMode(.middle)
                                            switch namesValidationError {
                                            case .empty, .containsInvalidCharacters, .exists:
                                                Image(systemName: "exclamationmark.triangle")
                                            case nil:
                                                EmptyView().frame(width: .zero, height: .zero)
                                            }
                                        }
                                        switch namesValidationError {
                                        case .empty, .containsInvalidCharacters, .exists:
                                            Text(namesValidationError?.localizedErrorText ?? "")
                                                .font(.footnote.weight(.bold))
                                                .foregroundStyle(.gray)
                                                .lineLimit(1)
                                                .truncationMode(.tail)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        case nil:
                                            EmptyView().frame(width: .zero, height: .zero)
                                        }
                                    }
                                }
                            }
                            .padding()
                            
                            if model.itemsLocalNameAndPath.count == 1 {
                                if let singleFile = model.itemsLocalNameAndPath.first, VCSFileType.USDZ.pathExt == singleFile.itemPathExtension, let scene = try? SCNScene(url: singleFile.itemURL, options: [.checkConsistency: true]), isKeyboardVisible == false {
                                    
                                    Divider()
                                    
                                    VStack {
                                        Text("Preview:")
                                            .font(.subheadline)
                                        SceneView(scene: { scene.background.contents = UIColor.systemBackground; return scene }(), options: [.autoenablesDefaultLighting, .allowsCameraControl])
                                            .scaledToFit()
    //                                            .frame(height: g.size.height*0.66)
                                    }
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $isFolderChooserPresented, content: {
                    FolderChooser(routeData: FCRouteData(folder: modelParentFolder), folderResult: $model.rootFolderResult) {
                        isFolderChooserPresented = false
                    }
                })
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .onReceive(keyboardPublisher) { newIsKeyboardVisible in
                    isKeyboardVisible = newIsKeyboardVisible
                }
            case .failure(let failure):
                VStack {
                    Label(title: {
                        Text(failure.localizedDescription)
                    }, icon: {
                        Image(systemName: "exclamationmark.triangle")
                    })
                    Button {
                        dismiss()
                    } label: {
                        Text("Close".vcsLocalized)
                    }
                }
            }
        } else {
            ProgressView()
                .controlSize(.extraLarge)
                .task {
                    model.loadHomeUserFolder()
                }
        }
    }
    
    private static func placeholder(fileExtension: String) -> UIImage {
        var imageName = "file"
        
        switch fileExtension.uppercased() {
        case VCSFileType.VWX.rawValue,
            VCSFileType.VWXP.rawValue,
            VCSFileType.VWXW.rawValue:
            imageName = "vectorworks"
        case VCSFileType.VGX.rawValue:
            imageName = "3d-file"
        case VCSFileType.PDF.rawValue:
            imageName = "pdf"
        case VCSFileType.IMG.rawValue:
            imageName = "image"
        case VCSFileType.TXT.rawValue:
            imageName = "text"
        case VCSFileType.VIDEO.rawValue:
            imageName = "video-file"
        default:
            imageName = "file"
        }
        
        let image = UIImage(named: imageName) ?? UIImage(systemName: "doc")
        return image!
    }
}

//#Preview {
////    let testFolder = VCSFolderResponse.testVCSFolder!
//    let model = FileUploadViewModel(itemsLocalNameAndPath: [
//        LocalFileNameAndPath(itemURL: URL(filePath: "/Users/a-teamiosdevsiosdevs/Downloads/artefino-gredi.pdf")),
//        LocalFileNameAndPath(itemURL: URL(filePath: "/Users/a-teamiosdevsiosdevs/Downloads/clean-architecture-swiftui-master.txt")),
//        LocalFileNameAndPath(itemURL: URL(filePath: "/Users/a-teamiosdevsiosdevs/Downloads/GB Stairs_20230331093005_20230331093133_95270001V6E48PU0_0.MP4")),
//        LocalFileNameAndPath(itemURL: URL(filePath: "/Users/a-teamiosdevsiosdevs/Downloads/Kushti_G_Bania__13_2_3_Ivailo_Fasadi_Izpulnenie.pdf")),
//        LocalFileNameAndPath(itemURL: URL(filePath: "/Users/a-teamiosdevsiosdevs/Downloads/zUI.vwx")),
//        LocalFileNameAndPath(itemURL: URL(filePath: "/Users/a-teamiosdevsiosdevs/Downloads/изискваня за издаване на констативен протокол за въвеждане в експлоатация.docx"))
//    ])
//    FileUploadView(model: model)
//        .environment(\.realmConfiguration, VCSRealmDB.realm.configuration)
//}
