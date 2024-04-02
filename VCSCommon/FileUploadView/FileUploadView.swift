import SwiftUI
import SceneKit

public struct FileUploadView: View, KeyboardReadable {
    @ObservedObject var model: FileUploadViewModel
    @State private var isKeyboardVisible = false
    
    var areNamesValid: Bool {
        model.itemsLocalNameAndPath.allSatisfy { FilenameValidator.isNameValid(ownerLogin: model.parentFolder.ownerLogin, storage: model.parentFolder.storageTypeString, prefix: model.parentFolder.prefix, name: $0.itemName) }
    }
    
    
    public init(model: FileUploadViewModel) {
        self.model = model
    }
    
    var generatedMessage: String {
        return "Upload Files".vcsLocalized
    }
    
    public var body: some View {
        GeometryReader { g in
            VStack(spacing: 0) {
                Text(self.generatedMessage)
                    .font(.title2)
                    .padding(.bottom)
                
                List {
                    ForEach(model.itemsLocalNameAndPath.indices, id: \.self) { idx in
                        VStack{
                            HStack {
                                Image(uiImage: FileUploadView.placeholder(fileExtension: model.itemsLocalNameAndPath[idx].itemPathExtension))
                                TextField("Please enter a filename.".vcsLocalized, text: $model.itemsLocalNameAndPath[idx].itemName)
                                    .onSubmit {
                                        guard $model.itemsLocalNameAndPath[idx].itemName.wrappedValue.count > 0 else { return }
                                        print($model.itemsLocalNameAndPath[idx].itemName)
                                    }
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .submitLabel(.done)
                                    .truncationMode(.middle)
                                if FilenameValidator.isNameValid(ownerLogin: model.parentFolder.ownerLogin, storage: model.parentFolder.storageTypeString, prefix: model.parentFolder.prefix, name: model.itemsLocalNameAndPath[idx].itemName) == false {
                                    Image(systemName: "exclamationmark.triangle")
                                }
                            }
                            if FilenameValidator.isNameValid(ownerLogin: model.parentFolder.ownerLogin, storage: model.parentFolder.storageTypeString, prefix: model.parentFolder.prefix, name: model.itemsLocalNameAndPath[idx].itemName) == false {
                                Text("Unsupported characters".vcsLocalized)
                                    .font(.footnote.weight(.bold))
                                    .foregroundStyle(.gray)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity, alignment: .leading)
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
                
                HStack {
                    Button {
                        model.isFolderChooserPresented = true
                    } label: {
                        Label(model.parentFolder.prefix, image: model.parentFolder.storageType.storageImageName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .tint(.label)
                .padding()
                .padding(.bottom)
                
                HStack {
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        model.cancelAction()
                    } label: {
                        Text("Discard".vcsLocalized)
                    }
                    Spacer()
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        model.uploadAction()
                    } label: {
                        Text("Upload".vcsLocalized)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(self.areNamesValid == false)
                }
                .padding()
            }
        }
        .sheet(isPresented: $model.isFolderChooserPresented, content: {
            FolderChooser(routeData: FCRouteData(folder: model.parentFolder), folderResult: $model.parentFolder)
        })
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            isKeyboardVisible = newIsKeyboardVisible
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
