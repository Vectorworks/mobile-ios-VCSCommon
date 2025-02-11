import SwiftUI
import SceneKit
import RealmSwift
import Realm
import Combine
import CocoaLumberjackSwift

public struct RCUploadView<Model>: View, KeyboardReadable where Model: RCFileUploadViewModel {
    @Environment(\.dismiss) var dismiss
    @ObservedObject public var model: Model
    
    @State var isKeyboardVisible = false
    
    private var dismissAction: (() -> Void)? = nil
    
    public init(model: Model, dismissAction: (() -> Void)? = nil) {
        self.model = model
        self.dismissAction = dismissAction
    }
    
    public var body: some View {
            switch model.rootFolderResult {
            case .success(let modelParentFolder):
                NavigationStack {
                    VStack {
                        UploadViewUploadProgressSection(model: model)
                        UploadViewFileName(model: model)
                        UploadViewLocationSection(model: model, modelParentFolder: modelParentFolder)
                    }
                    .navigationTitle("Save".vcsLocalized)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                if let dismissAction = dismissAction {
                                    dismissAction()
                                } else {
                                    dismiss()
                                }
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
                .interactiveDismissDisabled()
            
            case nil:
                VCSWideProgressView() {
                        model.loadInitialRootFolder()
                    }
            }
    }
}

public struct UploadViewUploadProgressSection<Model>: View where Model: FileUploadViewModel {
    @ObservedObject public var model: Model
    
    public init(model: Model) {
        self.model = model
    }
    
    public var body: some View {
        VStack {
            if model.isUploading {
                ProgressView(value: model.totalProgress, total: model.totalUploadsCount)
                Divider()
            }
        }
    }
}


public struct UploadViewFileName<Model>: View where Model: RCFileUploadViewModel {
    @ObservedObject public var model: Model
    
    var baseNameValidationError: FilenameValidationError? {
        let result = model.nameErrors()
        return result.first?.error
    }
    
    public init(model: Model) {
        self.model = model
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Name".vcsLocalized.uppercased())
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                HStack {
                    TextField("Please enter a filename.".vcsLocalized, text: $model.baseFileName)
                        .onSubmit {
                            guard model.baseFileName.count > 0 else { return }
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            print(model.baseFileName)
                        }
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.done)
                        .truncationMode(.middle)
                    if model.isUploading == false {
                        switch baseNameValidationError {
                        case .empty, .containsInvalidCharacters, .exists, .lengthy, .invalidUser:
                            Image(systemName: "exclamationmark.triangle")
                        case nil:
                            EmptyView().frame(width: .zero, height: .zero)
                        }
                    }
                }
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 10).fill(.background.secondary))
                if model.isUploading == false {
                    switch baseNameValidationError {
                    case .empty, .containsInvalidCharacters, .exists, .lengthy, .invalidUser:
                        Text(baseNameValidationError?.localizedErrorText ?? "")
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

public struct UploadViewLocationSection<Model>: View where Model: RCFileUploadViewModel {
    @Environment(\.dismiss) var dismiss
    @ObservedObject public var model: Model
    let modelParentFolder: VCSFolderResponse
    
    public init(model: Model, modelParentFolder: VCSFolderResponse) {
        self.model = model
        self.modelParentFolder = modelParentFolder
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Text("Location".vcsLocalized.uppercased())
                .font(.subheadline)
                .foregroundStyle(.gray)
            switch model.pickerProjectsBrowseOption {
            case .Simple:
                UploadViewSimpleLocation(model: model, modelParentFolder: modelParentFolder)
            case .Custom:
                UploadViewCustomLocation(model: model)
            }
        }
        .padding()
        
        Spacer()
        
        Button {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            model.uploadAction(dismiss: dismiss)
        } label: {
            HStack {
                Spacer()
                Text("Save".vcsLocalized)
                Spacer()
            }
        }
        .buttonStyle(.actionButtonRoundedCornerStyle)
        .disabled(model.isSaveButtonDisabled)
        .padding()
    }
}

public struct UploadViewSimpleLocation<Model>: View where Model: RCFileUploadViewModel {
    @ObservedObject public var model: Model
    let modelParentFolder: VCSFolderResponse
    
    @State var showSubfoldersList: Bool = false
    @State var showNewFolderTextField: Bool = false {
        didSet {
            model.hasNewFolderTextFieldVisible = showNewFolderTextField
        }
    }
    @State var newFolderName: String = ""
    @State var newFolderNameValidationError: FilenameValidationError? = nil
    @State var folderResult: Result<VCSFolderResponse, Error>?
    
    public init(model: Model, modelParentFolder: VCSFolderResponse) {
        self.model = model
        self.modelParentFolder = modelParentFolder
        if let lastProjectFolder = model.selectedFolder {
            folderResult = .success(lastProjectFolder)
        }
    }
    
    var newLocationValidationError: FilenameValidationError? {
        let result = model.isNewLocationNameError()
        return result?.error
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(modelParentFolder.storageType.storageImageName)
                Text(modelParentFolder.displayedPrefix)
            }
            if modelParentFolder.subfolders.count > 0 {
                switch folderResult {
                case .success(let success):
                    if success.exists {
                        Text(success.name)
                    } else {
                        Text("").frame(width: 0, height: 0)
                            .task {
                                model.lastSelectedFolderID = "nil"
                                showSubfoldersList = true
                            }
                    }
                case .failure(let failure):
                    Text("").frame(width: 0, height: 0)
                        .task {
                            model.lastSelectedFolderID = "nil"
                            showSubfoldersList = true
                        }
                case nil:
                    if let lastProjectFolder = VCSFolderResponse.realmStorage.getById(id: model.lastSelectedFolderID) {
                        VCSWideProgressView() {
                            model.loadFolder(folderURI: lastProjectFolder.resourceURI, folderResult: $folderResult)
                        }
                    } else {
                        Text("").frame(width: 0, height: 0)
                            .task {
                                model.lastSelectedFolderID = "nil"
                                showSubfoldersList = true
                            }
                    }
                }
                List(selection: Binding($model.lastSelectedFolderID)) {
                    Section(isExpanded: $showSubfoldersList) {
                        ForEach(modelParentFolder.subfolders, id: \.rID) { subfolder in
                            HStack {
                                Image(systemName: "folder")
                                    .foregroundStyle(.secondary)
                                Text(subfolder.name)
                                Spacer()
                            }
                            .tag(Optional(subfolder.rID))
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 10))
                        if showNewFolderTextField {
                            VStack {
                                HStack {
                                    TextField("Folder name".vcsLocalized, text: $newFolderName)
                                        .textFieldStyle(.roundedBorder)
                                        .onReceive(Just(newFolderName), perform: { newName in
                                            newFolderNameValidationError = FolderNameValidator.isNewFolderNameError(folderData: modelParentFolder, newFolderName: newName)?.error
                                        })
                                        .onSubmit {
                                            guard newFolderName.count > 0 else { return }
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                            guard newFolderNameValidationError == nil else { return }
                                            showNewFolderTextField = false
                                            APIClient.createFolder(storage: modelParentFolder.storageType, name: newFolderName, parentFolderPrefix: modelParentFolder.prefix, owner: modelParentFolder.ownerLogin).execute { (resultCreation: Result<VCSFolderResponse, Error>) in
                                                switch resultCreation {
                                                case .success(let success):
                                                    VCSCache.addToCache(item: success)
                                                    model.lastSelectedFolderID = success.rID
                                                case .failure(let failure):
                                                    DDLogError("FileUploadViewModel - firstLoadFolder(folderAssetURI:) - createFolder - error: \(failure)")
                                                }
                                                model.loadInitialRootFolder()
                                            }
                                        }
                                        .textInputAutocapitalization(.never)
                                        .disableAutocorrection(true)
                                        .submitLabel(.done)
                                        .truncationMode(.middle)
                                    switch newFolderNameValidationError {
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
                                switch newFolderNameValidationError {
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
                    } header: {
                        HStack {
                            Image(systemName: "folder")
                            Text("Select another location")
                        }
                        .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 0))
                    }
                }
                .contentMargins(.all, EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                .listStyle(.sidebar)
                .cornerRadius(10)
            } else {
                HStack {
                    TextField("Create a new folder for your scan".vcsLocalized, text: $model.newLocationName)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            guard model.newLocationName.count > 0 else { return }
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            print(model.newLocationName)
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
                }
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 10).fill(.background.secondary))
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
            
            HStack {
                Spacer()
                Button {
                    model.pickerProjectsBrowseOption = .Custom
                } label: {
                    Text("Custom".vcsLocalized.appending(" ..."))
                        .underline()
                }
            }
        }
    }
}

public struct UploadViewCustomLocation<Model>: View where Model: RCFileUploadViewModel {
    @ObservedObject public var model: Model
    
    public init(model: Model, folderResult: Result<VCSFolderResponse, Error>? = nil) {
        self.model = model
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            List(selection: Binding($model.lastSelectedFolderID)) {
                UploadViewCustomLocationSection(model: model, folderName: StorageType.S3.displayName, folderRID: StorageType.S3.itemIdentifier, folderPrefix: "", folderResourceURI: nil)
            }
            .contentMargins(.all, EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .cornerRadius(10)
            .task {
                model.loadHomeUserFolder()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    model.pickerProjectsBrowseOption = .Simple
                } label: {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Back".vcsLocalized)
                    }
                }
            }
        }
    }
}

public struct UploadViewCustomLocationSection<Model>: View where Model: FileUploadViewModel {
    @ObservedObject public var model: Model
    @State var folderResult: Result<VCSFolderResponse, Error>?
    @State var isSectionExpanded: Bool
    let folderName: String
    let folderRID: String
    let folderResourceURI: String?
    
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
                        UploadViewCustomLocationSection(model: model, folderName: subfolder.name, folderRID: subfolder.rID, folderPrefix: subfolder.prefix, folderResourceURI: subfolder.resourceURI)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 10))
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
    let model = RealityCaptureUploadViewModel(itemsLocalNameAndPath: [
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
            RCUploadView(model: model)
//                .presentationDetents([.fraction(0.75), .large])
//                .presentationDetents([.medium, .fraction(0.75), .large])
            
        }
}
