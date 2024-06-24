import SwiftUI
import CocoaLumberjackSwift

public struct FileChooser: View {
    @State var isPathSetup: Bool
    @State var path: [FCRouteData]
    @State var resultFolder: VCSFileResponse?
    @State var filterExtensions: [VCSFileType]
    var itemPickedCompletion: ((VCSFileResponse) -> Void)?
    var dismissChooser: (() -> Void)
    
    public init(isPathSetup: Bool = false, path: [FCRouteData] = [], resultFolder: VCSFileResponse? = nil, filterExtensions: [VCSFileType], itemPickedCompletion: ((VCSFileResponse) -> Void)? = nil, dismissChooser: @escaping (() -> Void)) {
        self.isPathSetup = isPathSetup
        self.path = path
        self.resultFolder = resultFolder
        self.filterExtensions = filterExtensions
        self.itemPickedCompletion = itemPickedCompletion
        self.dismissChooser = dismissChooser
    }
    
    public var body: some View {
        NavigationStack(path: $path) {
            let resourceURI = VCSUser.savedUser?.availableStorages.first(where: { $0.storageType == .S3 })?.folderURI ?? ""
            FileChooserSub(path: $path, resourceURI: resourceURI, filterExtensions: $filterExtensions, itemPickedCompletion: itemPickedCompletion, dismissChooser: dismissChooser, result: $resultFolder)
                .navigationDestination(for: FCRouteData.self) { routeValue in
                    FileChooserSub(path: $path, resourceURI: routeValue.resourceURI, filterExtensions: $filterExtensions, itemPickedCompletion: itemPickedCompletion, dismissChooser: dismissChooser, result: $resultFolder)
                }
        }
        .tint(.label)
//        .onAppear() {
//            if let folderResponse = routeData.folderResponse, isPathSetup == false {
//                isPathSetup = true
//                let routePrefixes = folderResponse.prefix.split(separator: "/")
//                var resourceURIBase = String(folderResponse.resourceURI.split(separator: "p:").first ?? "")
//                var isFirst = true
//                routePrefixes.forEach {
//                    let prefix = String($0)
//                    let pathComponent = isFirst ? "p:" + prefix : prefix
//                    isFirst = false
//                    resourceURIBase = resourceURIBase.appendingPathComponent(pathComponent).VCSNormalizedURLString()
//                    let pathRoute = FCRouteData(resourceURI: resourceURIBase, breadcrumbsName: prefix)
//                    
//                    path.append(pathRoute)
//                    DDLogDebug("Folder Chooser adding to path: \(pathRoute.resourceURI)")
//                }
//                DDLogDebug("Folder Chooser path value: \(path.compactMap({ $0.resourceURI }))")
//            }
//        }
    }
}

#Preview {
    FileChooser(filterExtensions: [VCSFileType.VWX], dismissChooser: {})
}
