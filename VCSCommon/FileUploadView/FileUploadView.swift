import SwiftUI
import SceneKit
import RealmSwift
import Realm
import Combine
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
                        dismissParent()
                    } label: {
                        Text("Discard".vcsLocalized)
                            .underline()
                    }
                }
            }
            .interactiveDismissDisabled()
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
                        dismiss()
                    } label: {
                        Text("Discard".vcsLocalized)
                            .underline()
                    }
                }
            }
        }
        .onReceive(keyboardPublisher) { newIsKeyboardVisible in
            isKeyboardVisible = newIsKeyboardVisible
        }
        .interactiveDismissDisabled()
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
        .disabled(model.hasNewFolderTextFieldVisible)
        .buttonStyle(.realityCaptureVisualEffectRoundedCornerStyle)
        .padding()
        .sheet(isPresented: $warningViewIsPresented) {
            FileUploadWarningView(model: model, dismissParent: dismiss)
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
                        FileUploadViewCustomLocationSection(model: model, folderData: modelParentFolder) {
                            model.rootFolderResult = nil
                        }
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
    @State var showNewFolderTextField: Bool = false {
        didSet {
            model.hasNewFolderTextFieldVisible = showNewFolderTextField
        }
    }
    @State var newFolderName: String = ""
    @State var newLocationValidationError: FilenameValidationError? = nil
    let reloadParentFolderLogic: () -> Void
    
    public init(model: Model, folderData: VCSFolderResponse, reloadParentFolderLogic: @escaping () -> Void) {
        self.model = model
        self.folderData = folderData
        self.reloadParentFolderLogic = reloadParentFolderLogic
    }
    
    public var body: some View {
        if folderData.subfolders.count > 0 {
            ForEach(folderData.subfolders, id: \.rID) { subfolder in
                SubFileUploadViewCustomLocationSection(model: model, folderName: subfolder.name, folderRID: subfolder.rID, folderPrefix: subfolder.prefix, folderResourceURI: subfolder.resourceURI)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 10))
        }
        if showNewFolderTextField {
            VStack {
                HStack {
                    TextField("Folder name".vcsLocalized, text: $newFolderName)
                        .textFieldStyle(.roundedBorder)
                        .onReceive(Just(newFolderName), perform: { newName in
                            newLocationValidationError = FolderNameValidator.isNewFolderNameError(folderData: folderData, newFolderName: newName)?.error
                        })
                        .onSubmit {
                            guard newFolderName.count > 0 else { return }
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            guard newLocationValidationError == nil else { return }
                            showNewFolderTextField = false
                            APIClient.createFolder(storage: folderData.storageType, name: newFolderName, parentFolderPrefix: folderData.prefix, owner: folderData.ownerLogin).execute { (resultCreation: Result<VCSFolderResponse, Error>) in
                                switch resultCreation {
                                case .success(let success):
                                    VCSCache.addToCache(item: success)
                                    model.lastSelectedFolderID = success.rID
                                case .failure(let failure):
                                    DDLogError("FileUploadViewModel - firstLoadFolder(folderAssetURI:) - createFolder - error: \(failure)")
                                }
                                reloadParentFolderLogic()
                            }
                        }
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.done)
                        .truncationMode(.middle)
                    switch newLocationValidationError {
                    case .empty, .containsInvalidCharacters, .exists, .lengthy, .invalidUser:
                        Image(systemName: "exclamationmark.triangle")
                    case nil:
                        EmptyView().frame(width: .zero, height: .zero)
                    }
                    Button(action: {
                        showNewFolderTextField = false
                        newFolderName = ""
                    }, label: {
                        Image(systemName: "xmark.circle")
                    })
                }
                switch newLocationValidationError {
                case .empty, .containsInvalidCharacters, .exists, .lengthy, .invalidUser:
                    Text(newLocationValidationError?.localizedErrorText ?? "")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                case nil:
                    EmptyView().frame(width: .zero, height: .zero)
                }
            }
        } else {
            if true { //ActionValidator.canCreateFolder(cellDataHolder: modelParentFolder) {
                Button(action: {
                    showNewFolderTextField = true
                    newFolderName = ""
                }, label: {
                    HStack {
                        Image(systemName: "folder.badge.plus")
                        Text("Create new".vcsLocalized)
                    }
                })
            }
        }
    }
}

public struct SubFileUploadViewCustomLocationSection<Model>: View where Model: FileUploadViewModel {
    @ObservedObject public var model: Model
    @State var folderResult: Result<VCSFolderResponse, Error>?
    @State var isSectionExpanded: Bool
    let folderName: String
    let folderRID: String
    let folderResourceURI: String?
    @State var showNewFolderTextField: Bool = false {
        didSet {
            model.hasNewFolderTextFieldVisible = showNewFolderTextField
        }
    }
    @State var newFolderName: String = ""
    @State var newLocationValidationError: FilenameValidationError? = nil
    
    public init(model: Model, folderName: String, folderRID: String, folderPrefix: String, folderResourceURI: String?) {
        self.model = model
        self.folderName = folderName
        self.folderRID = folderRID
        self.folderResourceURI = folderResourceURI
        
        let selectedFolderPrefix = model.selectedFolder?.prefix ?? ""
        if folderResourceURI == nil {
            self.isSectionExpanded = true
        } else if selectedFolderPrefix.contains(folderPrefix) && selectedFolderPrefix != folderPrefix {
            self.isSectionExpanded = true
        } else {
            self.isSectionExpanded = false
        }
    }
    
    public var body: some View {
        DisclosureGroup(isExpanded: $isSectionExpanded) {
            switch folderResult {
            case .success(let modelParentFolder):
                if modelParentFolder.subfolders.count > 0 {
                    ForEach(modelParentFolder.subfolders, id: \.rID) { subfolder in
                        SubFileUploadViewCustomLocationSection(model: model, folderName: subfolder.name, folderRID: subfolder.rID, folderPrefix: subfolder.prefix, folderResourceURI: subfolder.resourceURI)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 10))
                }
                if showNewFolderTextField {
                    VStack {
                        HStack {
                            TextField("Folder name".vcsLocalized, text: $newFolderName)
                                .textFieldStyle(.roundedBorder)
                                .onReceive(Just(newFolderName), perform: { newName in
                                    newLocationValidationError = FolderNameValidator.isNewFolderNameError(folderData: modelParentFolder, newFolderName: newName)?.error
                                })
                                .onSubmit {
                                    guard newFolderName.count > 0 else { return }
                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    guard newLocationValidationError == nil else { return }
                                    showNewFolderTextField = false
                                    APIClient.createFolder(storage: modelParentFolder.storageType, name: newFolderName, parentFolderPrefix: modelParentFolder.prefix, owner: modelParentFolder.ownerLogin).execute { (resultCreation: Result<VCSFolderResponse, Error>) in
                                        switch resultCreation {
                                        case .success(let success):
                                            VCSCache.addToCache(item: success)
                                            model.lastSelectedFolderID = success.rID
                                        case .failure(let failure):
                                            DDLogError("FileUploadViewModel - firstLoadFolder(folderAssetURI:) - createFolder - error: \(failure)")
                                        }
                                        folderResult = nil
                                    }
                                }
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .submitLabel(.done)
                                .truncationMode(.middle)
                            switch newLocationValidationError {
                            case .empty, .containsInvalidCharacters, .exists, .lengthy, .invalidUser:
                                Image(systemName: "exclamationmark.triangle")
                            case nil:
                                EmptyView().frame(width: .zero, height: .zero)
                            }
                            Button(action: {
                                showNewFolderTextField = false
                                newFolderName = ""
                            }, label: {
                                Image(systemName: "xmark.circle")
                            })
                        }
                        switch newLocationValidationError {
                        case .empty, .containsInvalidCharacters, .exists, .lengthy, .invalidUser:
                            Text(newLocationValidationError?.localizedErrorText ?? "")
                                .font(.footnote.weight(.bold))
                                .foregroundStyle(.gray)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        case nil:
                            EmptyView().frame(width: .zero, height: .zero)
                        }
                    }
                } else {
                    if true { //ActionValidator.canCreateFolder(cellDataHolder: modelParentFolder) {
                        Button(action: {
                            showNewFolderTextField = true
                            newFolderName = ""
                        }, label: {
                            HStack {
                                Image(systemName: "folder.badge.plus")
                                Text("Create new".vcsLocalized)
                            }
                        })
                    }
                }
            case .failure(let error):
                HStack {
                    Text("Error loading folder data".vcsLocalized)
                    Image(systemName: "exclamationmark.triangle")
                }
            case nil:
                VCSWideProgressView() {
                        if let folderResourceURI {
                            model.loadFolder(folderURI: folderResourceURI, folderResult: $folderResult)
                        } else if let userHomeFolderURI = VCSUser.savedUser?.availableStorages.first?.folderURI {
                            model.loadFolder(folderURI: userHomeFolderURI, folderResult: $folderResult)
                        } else {
                            folderResult = .failure(FilenameValidationError.invalidUser)
                        }
                    }
            }
        } label: {
            HStack {
                Image(systemName: "folder")
                    .foregroundStyle(.secondary)
                Text(folderName)
                Spacer()
            }
            .tag(Optional(folderRID))
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
