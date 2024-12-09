import SwiftUI
import SceneKit
import RealmSwift
import Realm
import CocoaLumberjackSwift

public struct FileUploadWarningView<Model>: View where Model: FileUploadViewModel {
    @Environment(\.dismiss) var dismiss
    var dismissParent: DismissAction
    @ObservedObject public var model: Model
    
    var sameNameMessage: String {
        return "File(s) with the same name already exist in your folder. Click Continue to overwrite. The previous file(s) will be available from their version history.".vcsLocalized
    }
    
    var invalidNameMessage: String {
        return "The following file name(s) contain unsupported characters.".vcsLocalized + " " +
             "A space at the beginning of the name is not allowed, and the following characters are invalid:".vcsLocalized + " " +
             String(format: VCSCommonConstants.invalidCharacterListStringFormat, "and".vcsLocalized)
    }
    
    var longNameMessage: String {
        return "The maximum length is 255 characters.".vcsLocalized.vcsLocalized
    }
    
    public init(model: Model, dismissParent: DismissAction) {
        self.model = model
        self.dismissParent = dismissParent
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                List {
                    if model.filesHasSameName.count > 0 {
                        Section(sameNameMessage) {
                            ForEach(model.filesHasSameName, id: \.name) { nameAndError in
                                Text(nameAndError.name)
                            }
                        }
                    }
                    
                    if model.filesHasInvalidName.count > 0 {
                        Section(invalidNameMessage) {
                            ForEach(model.filesHasInvalidName, id: \.name) { nameAndError in
                                Text(nameAndError.name)
                            }
                        }
                    }
                    
                    if model.filesHasLongName.count > 0 {
                        Section(longNameMessage) {
                            ForEach(model.filesHasLongName, id: \.name) { nameAndError in
                                Text(nameAndError.name)
                            }
                        }
                    }
                }
                .listStyle(.plain)
//                .padding()
                
                Spacer()
                
                HStack {
                    Button {
                        dismissParent()
//                        model.uploadAction(dismiss: dismiss)
                    } label: {
                        HStack {
                            Spacer()
                            Text("Cancel Upload".vcsLocalized)
                            Spacer()
                        }
                    }
                    .buttonStyle(.realityCaptureVisualEffectRoundedCornerStyle)
                    .padding()
                    
                    Spacer()
                    
                    Button {
                        model.uploadAction(dismiss: dismissParent)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Save".vcsLocalized)
                            Spacer()
                        }
                    }
                    .buttonStyle(.realityCaptureVisualEffectRoundedCornerStyle)
                    .padding()
                }
            }
            .navigationTitle("Warning".vcsLocalized)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        dismissParent()
                    } label: {
                        Text("Discard".vcsLocalized)
                            .underline()
                    }
                }
            }
        }
    }
}

public struct FileUploadView<Model>: View, KeyboardReadable where Model: FileUploadViewModel {
    @Environment(\.dismiss) var dismiss
    @ObservedObject public var model: Model
    
    @State var isKeyboardVisible = false
    
    public init(model: Model) {
        self.model = model
    }
    
    public var body: some View {
        NavigationStack {
            VStack {
                UploadViewUploadProgressSection(model: model)
                FileUploadViewLocationSection(model: model)
            }
            .navigationTitle("Save".vcsLocalized)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        dismiss()
                    } label: {
                        Text("Discard".vcsLocalized)
                            .underline()
                    }
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            isKeyboardVisible = newIsKeyboardVisible
        }
    }
}

public struct FileUploadViewLocationSection<Model>: View where Model: FileUploadViewModel {
    @Environment(\.dismiss) var dismiss
    @ObservedObject public var model: Model
    @State var warningViewIsPresented: Bool = false
    
    public init(model: Model) {
        self.model = model
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text("Location".vcsLocalized.uppercased())
                .font(.subheadline)
                .foregroundStyle(.gray)
            
            FileUploadViewCustomLocation(model: model)
        }
        .padding()
        
        Spacer()
        
        Button {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            if model.filesHasSameName.isEmpty == false || model.filesHasInvalidName.isEmpty == false || model.filesHasLongName.isEmpty == false {
                DDLogError("Files has errors.")
                if model.filesHasSameName.isEmpty == false {
                    DDLogError("Files has same name: \(model.filesHasSameName)")
                }
                if model.filesHasInvalidName.isEmpty == false {
                    DDLogError("Files has invalid name: \(model.filesHasInvalidName)")
                }
                if model.filesHasLongName.isEmpty == false {
                    DDLogError("Files has long name: \(model.filesHasLongName)")
                }
                warningViewIsPresented = true
                return
            }
            
            DDLogInfo("Files has not erros and uploading.")
            model.uploadAction(dismiss: dismiss)
        } label: {
            HStack {
                Spacer()
                Text("Save".vcsLocalized)
                Spacer()
            }
        }
        .buttonStyle(.realityCaptureVisualEffectRoundedCornerStyle)
        .padding()
        .sheet(isPresented: $warningViewIsPresented) {
            FileUploadWarningView(model: model, dismissParent: dismiss)
                .interactiveDismissDisabled()
        }
    }
}

public struct FileUploadViewCustomLocation<Model>: View where Model: FileUploadViewModel {
    @Environment(\.dismiss) var dismiss
    @ObservedObject public var model: Model
    @State var selectedStorage: Result<VCSStorageResponse, Error>?
    
    public init(model: Model) {
        self.model = model
        if let s3Storage = VCSUser.savedUser?.availableStorages.first {
            selectedStorage = .success(s3Storage)
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            switch (selectedStorage, model.rootFolderResult) {
            case (.success(let storage), .success(let modelParentFolder)):
                List(selection: Binding($model.lastSelectedFolderID)) {
                    Section {
                        FileUploadViewCustomLocationSection(model: model, folderData: modelParentFolder)
                    } header: {
                        let availableStoragesToShow = (VCSUser.savedUser?.availableStorages ?? []).filter({$0.storageType.itemIdentifier != storage.storageType.itemIdentifier})
                        if availableStoragesToShow.count > 0 {
                            Menu {
                                ForEach(availableStoragesToShow, id: \.storageType.itemIdentifier) { tmpStorage in
                                    Button {
                                        selectedStorage = .success(tmpStorage)
                                        model.rootFolderResult = nil
                                        model.lastSelectedFolderID = "nil"
                                    } label: {
                                        HStack {
                                            Image(tmpStorage.storageType.storageImageName)
                                            Spacer()
                                            Text(tmpStorage.storageType.displayName)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(storage.storageType.storageImageName)
                                    Text(storage.storageType.displayName)
                                    Image(systemName: "chevron.down")
                                }
                            }
                        } else {
                            HStack {
                                Image(storage.storageType.storageImageName)
                                Text(storage.storageType.displayName)
                            }
                        }
                    }
                }
                .contentMargins(.all, EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                .cornerRadius(10)
            case (.failure(let failure), _):
                VCSErrorView(error: failure.localizedDescription) { dismiss() }
            case (_, .failure(let failure)):
                VCSErrorView(error: failure.localizedDescription) { dismiss() }
            case (.success(let storage), .none):
                VCSWideProgressView() {
                    model.loadFolder(folderURI: storage.folderURI, folderResult: $model.rootFolderResult)
                }
            case (.none, _):
                VCSWideProgressView() {
                    Task {
                        let result = await VCSStorageResponse.loadUserStorages()
                        switch result {
                        case .success(let success):
                            if let s3Storage = success.first {
                                selectedStorage = .success(s3Storage)
                            } else {
                                selectedStorage = .failure(VCSError.noInitialData)
                            }
                        case .failure(let failure):
                            selectedStorage = .failure(failure)
                        }
                    }
                }
            }
        }
        
    }
}

public struct FileUploadViewCustomLocationSection<Model>: View where Model: FileUploadViewModel {
    @ObservedObject public var model: Model
    let folderData: VCSFolderResponse
    
    public init(model: Model, folderData: VCSFolderResponse) {
        self.model = model
        self.folderData = folderData
    }
    
    public var body: some View {
        if folderData.subfolders.count > 0 {
            ForEach(folderData.subfolders, id: \.rID) { subfolder in
                UploadViewCustomLocationSection(model: model, folderName: subfolder.name, folderRID: subfolder.rID, folderPrefix: subfolder.prefix, folderResourceURI: subfolder.resourceURI)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 10))
        }
    }
}

#Preview {
    let testFolder = VCSFolderResponse.testVCSFolder!
    let model = FileImportUploadViewModel(itemsLocalNameAndPath: [
        LocalFileNameAndPath(itemURL: URL(filePath: "/Users/a-teamiosdevsiosdevs/Downloads/artefino-gredi.pdf")),
        //        LocalFileNameAndPath(itemURL: URL(filePath: "/Users/a-teamiosdevsiosdevs/Downloads/clean-architecture-swiftui-master.txt")),
        //        LocalFileNameAndPath(itemURL: URL(filePath: "/Users/a-teamiosdevsiosdevs/Downloads/GB Stairs_20230331093005_20230331093133_95270001V6E48PU0_0.MP4")),
        //        LocalFileNameAndPath(itemURL: URL(filePath: "/Users/a-teamiosdevsiosdevs/Downloads/Kushti_G_Bania__13_2_3_Ivailo_Fasadi_Izpulnenie.pdf")),
        //        LocalFileNameAndPath(itemURL: URL(filePath: "/Users/a-teamiosdevsiosdevs/Downloads/zUI.vwx")),
        //        LocalFileNameAndPath(itemURL: URL(filePath: "/Users/a-teamiosdevsiosdevs/Downloads/изискваня за издаване на констативен протокол за въвеждане в експлоатация.docx"))
    ])
    let _ = model.rootFolderResult = .success(testFolder)
    Text("ASD")
        .sheet(isPresented: .constant(true)) {
            FileUploadView(model: model)
            //                .presentationDetents([.fraction(0.75), .large])
            //                .presentationDetents([.medium, .fraction(0.75), .large])
            
        }
}
