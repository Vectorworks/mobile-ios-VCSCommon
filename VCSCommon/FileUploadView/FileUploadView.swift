import SwiftUI

public struct FileUploadView: View {
    @ObservedObject var model: FileUploadViewModel
    
    
    public init(model: FileUploadViewModel) {
        self.model = model
    }
    
    var generatedMessage: String {
        //        var result = self.model.message + "\n" + "\(self.uploadFolder.displayedPrefix)"
        //        if self.model.isChangeNameEnabled {
        //            result = result + "\n" + "With the following name:".vcsLocalized + "\n" + self.newFileName
        //        }
        //
        //        return result
        
        return "The following files will be uploaded:".vcsLocalized
    }
    
    public var body: some View {
        VStack {
            Text(self.generatedMessage)
                .font(.headline)
            
            List {
                ForEach(model.itemsLocalNameAndPath.indices, id: \.self) { idx in
                    TextField("Filename".vcsLocalized, text: $model.itemsLocalNameAndPath[idx].itemName)
                        .disabled(model.itemsLocalNameAndPath.count > 1)
                        .onSubmit {
                            guard $model.itemsLocalNameAndPath[idx].itemName.wrappedValue.count > 0 else { return }
                            print($model.itemsLocalNameAndPath[idx].itemName)
                        }
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.done)
                }
            }.onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            
            HStack {
                Button {
                    model.isFolderChooserPresented = true
                } label: {
                    Label(model.parentFolder.prefix, image: model.parentFolder.storageType.storageImageName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
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
                    model.uploadAction()
                } label: {
                    Text("Upload".vcsLocalized)
                }
            }
            .padding()
        }
        .sheet(isPresented: $model.isFolderChooserPresented, content: {
            FolderChooser(routeData: FCRouteData(folder: model.parentFolder), folderResult: $model.parentFolder, isPresented: $model.isFolderChooserPresented)
        })
    }
}
