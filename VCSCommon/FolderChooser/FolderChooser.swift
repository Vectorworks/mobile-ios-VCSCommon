import SwiftUI
import CocoaLumberjackSwift

public struct FolderChooser: View {
    @State var isPathSetup: Bool = false
    @State var path: [FCRouteData] = []
    @State var routeData: FCRouteData
    @State var rootRouteData: FCRouteData
    @Binding var folderResult: Result<VCSFolderResponse, Error>?
    
    public init(routeData: FCRouteData, folderResult: Binding<Result<VCSFolderResponse, Error>?>) {
        self.routeData = routeData
        self._folderResult = folderResult
        
        if routeData.resourceURI.contains("/p:"), let resourceURI = routeData.resourceURI.split(separator: "/p:").first {
            self.rootRouteData = FCRouteData(resourceURI: String(resourceURI).VCSNormalizedURLString(), breadcrumbsName: routeData.folderResponse?.storageType.displayName ?? "")
        } else {
            self.rootRouteData = routeData
        }
    }
    
    public var body: some View {
        NavigationStack(path: $path) {
            FolderChooserSub(path: $path, rootRouteData: $rootRouteData, routeData: rootRouteData, loadingFolder: rootRouteData.folderResult, result: $folderResult)
                .navigationDestination(for: FCRouteData.self) { routeValue in
                    FolderChooserSub(path: $path, rootRouteData: $rootRouteData, routeData: routeValue, loadingFolder: routeValue.folderResult, result: $folderResult)
                }
        }
        .tint(.label)
        .onAppear() {
            if let folderResponse = routeData.folderResponse, isPathSetup == false {
                isPathSetup = true
                let routePrefixes = folderResponse.prefix.split(separator: "/")
                var resourceURIBase = String(folderResponse.resourceURI.split(separator: "p:").first ?? "")
                var isFirst = true
                routePrefixes.forEach {
                    let prefix = String($0)
                    let pathComponent = isFirst ? "p:" + prefix : prefix
                    isFirst = false
                    resourceURIBase = resourceURIBase.appendingPathComponent(pathComponent).VCSNormalizedURLString()
                    let pathRoute = FCRouteData(resourceURI: resourceURIBase, breadcrumbsName: prefix)
                    
                    path.append(pathRoute)
                    DDLogDebug("Folder Chooser adding to path: \(pathRoute.resourceURI)")
                }
                DDLogDebug("Folder Chooser path value: \(path.compactMap({ $0.resourceURI }))")
            }
        }
    }
}

struct FolderChooser_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FolderChooser(routeData: FCRouteData(resourceURI: VCSFolderResponse.testVCSFolder?.resourceURI ?? "", breadcrumbsName: VCSFolderResponse.testVCSFolder?.prefix.lastPathComponent ?? ""), folderResult: .constant(.success(VCSFolderResponse.testVCSFolder!)))
            //            FolderChooser(currentFolder: RealmFolder(model: VCSFolderResponse.testVCSFolder!)).previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
        }
    }
}

