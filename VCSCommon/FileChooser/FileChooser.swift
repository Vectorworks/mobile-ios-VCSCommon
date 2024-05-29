import SwiftUI
import CocoaLumberjackSwift

public struct FileChooser: View {
    @State var isPathSetup: Bool = false
    @State var path: [FCRouteData] = []
    @State var resultFolder: VCSFileResponse? = nil
    @State var filterExtensions: [VCSFileType]
    
    public init(isPathSetup: Bool = false, path: [FCRouteData] = [], resultFolder: VCSFileResponse? = nil, filterExtensions: [VCSFileType]) {
        self.isPathSetup = isPathSetup
        self.path = path
        self.resultFolder = resultFolder
        self.filterExtensions = filterExtensions
    }
    
    public var body: some View {
        NavigationStack(path: $path) {
            let resourceURI = VCSUser.savedUser?.availableStorages.first(where: { $0.storageType == .S3 })?.folderURI ?? ""
            FileChooserSub(path: $path, resourceURI: resourceURI, filterExtensions: $filterExtensions, result: $resultFolder)
                .navigationDestination(for: FCRouteData.self) { routeValue in
                    FileChooserSub(path: $path, resourceURI: routeValue.resourceURI, filterExtensions: $filterExtensions, result: $resultFolder)
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
    FileChooser(filterExtensions: [VCSFileType.VWX])
}
