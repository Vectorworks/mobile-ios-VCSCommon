import SwiftUI

public struct FileUploadView: View {
    @ObservedObject var model: FileUploadViewModel
    
    
    public init(model: FileUploadViewModel) {
        self.model = model
    }
    
    var generatedMessage: String {
        return "Upload Files".vcsLocalized
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Text(self.generatedMessage)
                .font(.title2)
                .padding(.bottom)
            
            List {
                ForEach(model.itemsLocalNameAndPath.indices, id: \.self) { idx in
                    HStack {
                        Image(uiImage: FileUploadView.placeholder(fileExtension: model.itemsLocalNameAndPath[idx].itemPathExtension))
                        TextField("Filename".vcsLocalized, text: $model.itemsLocalNameAndPath[idx].itemName)
                            .onSubmit {
                                guard $model.itemsLocalNameAndPath[idx].itemName.wrappedValue.count > 0 else { return }
                                print($model.itemsLocalNameAndPath[idx].itemName)
                            }
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .submitLabel(.done)
                            .truncationMode(.middle)
                    }
                    
                }
            }
            .listStyle(.plain)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
            .tint(Color(UIColor.label))
            .padding()
            .padding(.bottom)
            
            HStack {
                Button {
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
            }
            .padding()
        }
        .sheet(isPresented: $model.isFolderChooserPresented, content: {
            FolderChooser(routeData: FCRouteData(folder: model.parentFolder), folderResult: $model.parentFolder, isPresented: $model.isFolderChooserPresented)
        })
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
