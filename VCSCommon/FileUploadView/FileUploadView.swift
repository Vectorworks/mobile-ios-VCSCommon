import SwiftUI
import SceneKit

public struct FileUploadView: View, KeyboardReadable {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject public var model: FileUploadViewModel
    
    @State public var isFolderChooserPresented = false
    @State public var isKeyboardVisible = false
    
    public init(model: FileUploadViewModel, isFolderChooserPresented: Bool = false, isKeyboardVisible: Bool = false) {
        self.model = model
        self.isFolderChooserPresented = isFolderChooserPresented
        self.isKeyboardVisible = isKeyboardVisible
    }
    
    var generatedMessage: String {
        return "Upload Files".vcsLocalized
    }
    
    public var body: some View {
        if let parentFolderResult = model.folderResult {
            switch parentFolderResult {
            case .success(let modelParentFolder):
                GeometryReader { g in
                    VStack(spacing: 0) {
                        Text(self.generatedMessage)
                            .font(.title2)
                            .padding(.bottom)
                        
                        List {
                            ForEach(model.itemsLocalNameAndPath.indices, id: \.self) { idx in
                                let currentItem = model.itemsLocalNameAndPath[idx]
                                let currentItemBinding = $model.itemsLocalNameAndPath[idx]
                                VStack{
                                    HStack {
                                        Image(uiImage: FileUploadView.placeholder(fileExtension: currentItem.itemPathExtension))
                                        TextField("Please enter a filename.".vcsLocalized, text: currentItemBinding.itemName)
                                            .onSubmit {
                                                guard currentItemBinding.itemName.wrappedValue.count > 0 else { return }
                                                print(currentItemBinding.itemName)
                                            }
                                            .textInputAutocapitalization(.never)
                                            .disableAutocorrection(true)
                                            .submitLabel(.done)
                                            .truncationMode(.middle)
                                        if FilenameValidator.isNameValid(ownerLogin: modelParentFolder.ownerLogin, storage: modelParentFolder.storageTypeString, prefix: modelParentFolder.prefix, name: currentItem.itemName) == false {
                                            Image(systemName: "exclamationmark.triangle")
                                        }
                                    }
                                    if FilenameValidator.isNameValid(ownerLogin: modelParentFolder.ownerLogin, storage: modelParentFolder.storageTypeString, prefix: modelParentFolder.prefix, name: currentItem.itemName) == false {
                                        Text("Unsupported characters".vcsLocalized)
                                            .font(.footnote.weight(.bold))
                                            .foregroundStyle(.gray)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    if let uploadingItemID = model.itemsUploading[currentItem.itemURL], let progress = model.itemsUploadProgress[uploadingItemID] {
                                        if progress == ProgressValues.Started.rawValue {
                                            ProgressView(value: 0)
                                        } else if progress == ProgressValues.Finished.rawValue {
                                            ProgressView(value: 1)
                                        } else {
                                            ProgressView(value: progress)
                                        }
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .onTapGesture {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        
                        if let singleFile = model.itemsLocalNameAndPath.first, VCSFileType.USDZ.pathExt == singleFile.itemPathExtension, let scene = try? SCNScene(url: singleFile.itemURL, options: [.checkConsistency: true]), isKeyboardVisible == false {
                            SceneView(scene: { scene.background.contents = UIColor.systemBackground; return scene }(), options: [.autoenablesDefaultLighting, .allowsCameraControl])
                                .frame(height: g.size.height*0.66)
                        }
                        
                        Divider()
                        if model.itemsUploadProgress.count > 0 {
                            ProgressView(value: model.completedUnitCount, total: model.totalUnitCount)
                            Divider()
                        }
                        
                        HStack {
                            Button {
                                isFolderChooserPresented = true
                            } label: {
                                Label(modelParentFolder.prefix, image: modelParentFolder.storageType.storageImageName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .tint(.label)
                        .padding()
                        .padding(.bottom)
                        
                        HStack {
                            Button {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                dismiss()
                            } label: {
                                Text("Discard".vcsLocalized)
                            }
                            Spacer()
                            Button {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                                model.uploadAction(dismiss: dismiss)
                                model.uploadAction(parentFolder: modelParentFolder, dismiss: dismiss)
                            } label: {
                                Text("Upload".vcsLocalized)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.areNamesValid(parentFolder: modelParentFolder) == false || model.isUploading == true)
                        }
                        .padding()
                    }
                }
                .sheet(isPresented: $isFolderChooserPresented, content: {
                    FolderChooser(routeData: FCRouteData(folder: modelParentFolder), folderResult: $model.folderResult)
                })
                .onReceive(keyboardPublisher) { newIsKeyboardVisible in
                    isKeyboardVisible = newIsKeyboardVisible
                }
            case .failure(let failure):
                VStack {
                    Label(title: {
                        Text(failure.localizedDescription)
                    }, icon: {
                        Image(systemName: "status-warning-big")
                    })
                    Text(failure.localizedDescription)
                    Divider()
                    Button {
                        dismiss()
                    } label: {
                        Text("Close".vcsLocalized)
                    }
                }
            }
        } else {
            ProgressView()
                .modify({
                    if #available(iOS 17.0, *) {
                        $0.controlSize(.extraLarge)
                    } else {
                        $0.controlSize(.large)
                    }
                })
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
