import Foundation
import UIKit
import RealmSwift
import SwiftUI
import CocoaLumberjackSwift

class FileChooserViewModel: ObservableObject {
    
    public static var linksPredicate: NSPredicate {
        var predicate = NSPredicate(format: "isSampleFiles == false AND owner == nil")
        if let ownerLogin = VCSUser.savedUser?.login {
            predicate = NSPredicate(format: "isSampleFiles == false AND owner.RealmID == %@", ownerLogin)
        }
        return predicate
    }
    
    @Published var sections: [RouteSection]
    
    @Published var viewState: FileChooserViewState = .loading
            
    var fileTypeFilter: FileTypeFilter
    
    var isGuest: Bool
    
    init(
        fileTypeFilter: FileTypeFilter,
        mainRoute: FileChooserRouteData,
        isGuest: Bool
    ) {
        self.fileTypeFilter = fileTypeFilter
        self.isGuest = isGuest
        self.sections = FileChooserViewModel.getSectionsForMainRoute(mainRoute: mainRoute, isGuest: isGuest, fileTypeFilter: fileTypeFilter)
    }
    
    static func getSectionsForMainRoute(
        mainRoute: FileChooserRouteData,
        isGuest: Bool,
        fileTypeFilter: FileTypeFilter
    ) -> [RouteSection] {
        var routes: [FileChooserRouteData] = [mainRoute]
        if isGuest {
            routes.append(.sampleFiles)
        } else {
            routes.append(.sharedWithMe)
        }
        
        return routes.enumerated().map { index, route in
            RouteSection(
                route: route,
                index: index,
                fileTypeStates: getInitialFileTypeStatesForRoute(route: route, fileTypeFilter: fileTypeFilter)
            )
        }
    }
    
    static func getInitialFileTypeStatesForRoute(route: FileChooserRouteData, fileTypeFilter: FileTypeFilter) -> [String: FileTypePaginationState] {
        var fileTypeStates: [String: FileTypePaginationState] = [:]
        for fileType in fileTypeFilter.extensions {
            fileTypeStates[fileType.rawValue] = FileTypePaginationState(currentPage: 0, hasMorePages: true)
        }
        return fileTypeStates
    }
    
    func updateFileTypeState(
        for route: FileChooserRouteData,
        fileType: String,
        nextPage: Int? = nil,
        hasMorePages: Bool? = nil
    ) {
        DispatchQueue.main.async { [self] in
            guard let index = self.sections.firstIndex(where: { $0.route == route }) else { return }
            
            guard let fileTypeState = self.sections[index].fileTypeStates[fileType] else { return }
            
            let newState = FileTypePaginationState(
                currentPage: nextPage ?? fileTypeState.currentPage + 1,
                hasMorePages: hasMorePages ?? fileTypeState.hasMorePages
            )
            
            self.sections[index].fileTypeStates[fileType] = newState
        }
    }
    
    func fileTypesWithNextPage(route: FileChooserRouteData) -> [String] {
        guard let index = self.sections.firstIndex(where: { $0.route == route }) else { return [] }
        
        let fileTypeStates = self.sections[index].fileTypeStates
        
        return fileTypeStates
            .filter { fileType, state in state.hasMorePages }
            .map { $0.key }
    }
    
    func getState(for section: RouteSection) -> AggregatedState {
        if section.isLoading {
            return .loading
        }
        
        let hasMorePages = section.fileTypeStates.values.contains { $0.hasMorePages }
        return hasMorePages ? .hasNextPage : .noMorePages
    }
    
    func setSectionLoading(sectionIndex: Int, isLoading: Bool) {
        DispatchQueue.main.async {
            self.sections[sectionIndex].isLoading = isLoading
            self.sections[sectionIndex].shouldRefresh = true
            
            if isLoading {
                self.changeViewState(to: .loading)
            } else {
                self.changeViewState(to: .loaded)
            }
        }
    }
    
    func updateSections(newMainRoute: FileChooserRouteData) async {
        DispatchQueue.main.async { [self] in
            sections[0] = RouteSection(route: newMainRoute, index: 0, fileTypeStates: FileChooserViewModel.getInitialFileTypeStatesForRoute(route: newMainRoute, fileTypeFilter: fileTypeFilter))
        }
        
        do {
            try await loadInitialDataForSection(section: sections[0])
        } catch {
            handleError(error)
        }
    }
    
    func changeViewState(to viewState: FileChooserViewState) {
        DispatchQueue.main.async { [self] in
            self.viewState = viewState
        }
    }
    
    func loadInitialData() async {
        do {
            updatePaginationWithLoadedFiles()
            
            for section in sections {
                try await loadInitialDataForSection(section: section)
            }
        } catch {
            handleError(error)
        }
    }
    
    func loadInitialDataForSection(section: RouteSection) async throws {
        setSectionLoading(sectionIndex: section.index, isLoading: true)
        
        for ext in fileTypeFilter.extensions.map { $0.rawValue } {
            let query = ".\(ext)"
            
            switch section.route {
            case .s3, .dropbox, .oneDrive, .googleDrive:
                try await loadCurrentStorageNextPage(route: section.route, ext: ext)
                
            case .sharedWithMe:
                let hasMorePages: Bool
                
                try await loadAndSaveSharedLinksContents()
                
                if !isGuest {
                    let sharedWithMeSection = sections.first { $0.route == .sharedWithMe }
                    let sharedWithMeNextPage = sharedWithMeSection?.fileTypeStates[ext]?.currentPage ?? 0
                    let sharedWithMeResponse = try await APIClient.searchSharedWithMe(query: query, page: sharedWithMeNextPage, related: true)
                    
                    hasMorePages = sharedWithMeResponse.next != nil
                    
                    sharedWithMeResponse.results
                        .forEach {
                            $0.asset.loadLocalFiles()
                            VCSCache.addToCache(item: $0)
                        }
                } else {
                    hasMorePages = false
                }
                
                updateFileTypeState(for: FileChooserRouteData.sharedWithMe, fileType: ext, hasMorePages: hasMorePages)
                
            case .sampleFiles:
                try await loadAndSaveSampleFilesContents()
            }
            
        }
        
        setSectionLoading(sectionIndex: section.index, isLoading: false)
        
        DispatchQueue.main.async { [self] in
            sections[section.index].isInitialDataLoaded = true
        }
    }
    
    func loadNextPage(section: RouteSection) async {
        setSectionLoading(sectionIndex: section.index, isLoading: true)
        
        for ext in fileTypesWithNextPage(route: section.route) {
            do {
                switch section.route {
                case .s3, .dropbox, .oneDrive, .googleDrive:
                    try await loadCurrentStorageNextPage(route: section.route, ext: ext)
                    
                case .sharedWithMe:
                    let sharedWithMeSection = sections.first { $0.route == .sharedWithMe }
                    let sharedWithMeNextPage = sharedWithMeSection?.fileTypeStates[ext]?.currentPage ?? 0
                    let sharedWithMeResponse = try await APIClient.searchSharedWithMe(query: ".\(ext)", page: sharedWithMeNextPage, related: true)
                    
                    updateFileTypeState(for: FileChooserRouteData.sharedWithMe, fileType: ext, hasMorePages: sharedWithMeResponse.next != nil)
                    
                    sharedWithMeResponse.results
                        .forEach {
                            $0.asset.loadLocalFiles()
                            VCSCache.addToCache(item: $0)
                        }
                    
                default:
                    break
                }
                
            } catch {
                handleError(error)
            }
        }
        setSectionLoading(sectionIndex: section.index, isLoading: false)
    }
    
    func loadCurrentStorageNextPage(route: FileChooserRouteData, ext: String) async throws {
        let query = ".\(ext)"
        let currentSection = sections.first { $0.route == route }
        let currentStorageNextPage = currentSection?.fileTypeStates[ext]?.currentPage ?? 0
        let currentStorageResponse = try await APIClient.search(query: query, storageType: route.storageType.rawValue, page: currentStorageNextPage, related: true)
        
        updateFileTypeState(for: route, fileType: ext, hasMorePages: currentStorageResponse.next != nil)
        //TODO: remove debug string
        let itemsAndRelatedDebugString = currentStorageResponse.results.map({"\($0.asset.name) -rel-> \(($0.asset as? VCSFileResponse)?.related.map({$0.name})))"})
        DDLogInfo("Items and Related:\n\(itemsAndRelatedDebugString.joined(separator: "\n"))")
        currentStorageResponse.results
            .map { $0.asset }
            .forEach {
                $0.loadLocalFiles()
                VCSCache.addToCache(item: $0)
            }
    }
    
    func updatePaginationWithLoadedFiles() {
        DispatchQueue.main.async { [self] in
            for section in sections {
                let route = section.route
                let models = section.models
                
                let filterExtensionsWithMorePages = fileTypesWithNextPage(route: route)
                
                for fileExtension in filterExtensionsWithMorePages {
                    let totalFilesInDatabaseCount = models
                        .filter { $0.name.range(of: fileExtension, options: .caseInsensitive) != nil }
                        .count
                    
                    let pageSize = 100
                    
                    let fullyLoadedPages = totalFilesInDatabaseCount / pageSize
                    
                    let remainingFilesOnPartialPage = totalFilesInDatabaseCount % pageSize
                    
                    let nextPageToRequest = remainingFilesOnPartialPage == 0 ? (fullyLoadedPages + 1) : fullyLoadedPages + 1
                    
                    updateFileTypeState(for: route, fileType: fileExtension, nextPage: nextPageToRequest)
                }
            }
        }
    }
    
    func loadAndSaveSharedLinksContents() async throws {
        let cachedSharedLinks = SharedLink.realmStorage.getAll(predicate: FileChooserViewModel.linksPredicate)
        
        for link in cachedSharedLinks {
            if let folder = link.sharedAsset?.asset as? VCSFolderResponse {
                for subfolder in folder.subfolders {
                    try await self.fetchAndSaveFolder(resourceUri: subfolder.resourceURI, isSampleFiles: false)
                }
            }
        }
    }
    
    func loadAndSaveSampleFilesContents() async throws {
        let folderURI = "/links/:samples/:metadata/"
        
        let sampleFilesLink = VCSServer.default.serverURLString.stringByAppendingPath(path: folderURI)
        
        let predicate = NSPredicate(format: "RealmID = %@", sampleFilesLink)
        let cachedSampleFilesLink = SharedLink.realmStorage.getAll(predicate: predicate).first
        
        let loadedSampleFilesSubfoldersCount = (cachedSampleFilesLink?.sharedAsset?.asset as? VCSFolderResponse)?.subfolders.filter { !$0.subfolders.isEmpty }.count
        
        if loadedSampleFilesSubfoldersCount == nil || loadedSampleFilesSubfoldersCount == 0 {
            let sampleFolderResponse = try await APIClient.linkSharedAssetAsync(assetURI: folderURI)
            
            sampleFolderResponse.asset.loadLocalFiles()
            
            let updatedSampleFilesLink = SharedLink(link: sampleFilesLink, isSampleFiles: true, sharedAsset: sampleFolderResponse, owner: VCSUser.savedUser)
            
            VCSCache.addToCache(item: updatedSampleFilesLink, forceNilValuesUpdate: true)
            
            if let folder = sampleFolderResponse.asset as? VCSFolderResponse {
                for subfolder in folder.subfolders {
                    try await self.fetchAndSaveFolder(resourceUri: subfolder.resourceURI, isSampleFiles: true)
                }
            }
        }
    }
    
    func fetchAndSaveFolder(resourceUri: String, isSampleFiles: Bool) async throws {
        do {
            let response = try await APIClient.linkSharedAssetAsync(assetURI: resourceUri)
            response.asset.loadLocalFiles()
            VCSCache.addToCache(item: response)
            
            if let folder = response.asset as? VCSFolderResponse {
                for subfolder in folder.subfolders {
                    try await self.fetchAndSaveFolder(resourceUri: subfolder.resourceURI, isSampleFiles: isSampleFiles)
                }
            }
            
        } catch (let error) {
            throw error
        }
    }
    
    func filterAndMapToModelsForCurrentStorage(
        allFiles: Results<VCSFileResponse.RealmModel>,
        section: RouteSection,
        isOnline: Bool
    ) {
        var models: [FileChooserModel] = []
        
        let currentStorageFiles = allFiles
            .filter { $0.storageType == section.route.storageType.rawValue }
            .sorted(by: { $0.lastModified > $1.lastModified })
            .map {
                FileChooserModel(
                    resourceUri: $0.resourceURI,
                    resourceId: $0.resourceID,
                    flags: $0.flags?.entityFlat,
                    name: $0.name,
                    thumbnailUrl: $0.thumbnailURL,
                    lastDateModified: $0.lastModified.toDate(),
                    isAvailableOnDevice: $0.isAvailableOnDevice,
                    fileType: $0.fileType
                )
            }
        
        models.append(contentsOf: currentStorageFiles)
        
        let resultsFiltered = models.matchesFilter(fileTypeFilter, isOnline: isOnline)
        
        DispatchQueue.main.async { [self] in
            sections[section.index].models = resultsFiltered
            sections[section.index].shouldRefresh = false
        }
    }
    
    func setSectionsShouldRefresh() {
        for section in self.sections {
            self.sections[section.index].shouldRefresh = true
        }
    }
    
    func filterAndMapToModelsForSharedWithMe(
        allSharedItems: Results<VCSSharedWithMeAsset.RealmModel>,
        sharedLinks: Results<SharedLink.RealmModel>,
        isOnline: Bool,
        sectionIndex: Int
    ) {
        var models: [FileChooserModel] = []
        
        allSharedItems.forEach {
            if $0.assetType == AssetType.file.rawValue {
                models.append(FileChooserModel(
                    resourceUri: $0.resourceURI,
                    resourceId: $0.RealmID,
                    flags: $0.entity.asset.flags,
                    name: $0.entity.name,
                    thumbnailUrl: $0.entity.thumbnailURL,
                    lastDateModified: $0.entity.lastModifiedString.toDate(),
                    isAvailableOnDevice: $0.entity.isAvailableOnDevice,
                    fileType: $0.entity.fileTypeString
                ))
            }
        }
        
        models.append(contentsOf: convertSharedLinksToFileChooserModels(sharedLinks: sharedLinks))
        
        let sharedFilesFiltered = models.matchesFilter(fileTypeFilter, isOnline: isOnline)
        
        DispatchQueue.main.async { [self] in
            sections[sectionIndex].models = sharedFilesFiltered
            sections[sectionIndex].shouldRefresh = false
        }
    }
    
    func populateSampleFilesSectionForGuest(isOnline: Bool, sectionIndex: Int) {
        if isGuest {
            let sampleFilesLink = VCSServer.default.serverURLString.stringByAppendingPath(
                path: "/links/:samples/:metadata/")
            let predicate = NSPredicate(format: "RealmID = %@", sampleFilesLink)
            let cachedSampleFilesLink = SharedLink.realmStorage.getAll(predicate: predicate).first
            
            if let sampleFilesMainFolder = cachedSampleFilesLink?.sharedAsset?.asset as? VCSFolderResponse {
                let sampleFilesResultsFiltered = getAllFiles(from: sampleFilesMainFolder).matchesFilter(fileTypeFilter, isOnline: isOnline)
                
                DispatchQueue.main.async { [self] in
                    sections[sectionIndex].models = sampleFilesResultsFiltered
                    sections[sectionIndex].shouldRefresh = false
                }
            }
        }
    }
    
    func convertSharedLinksToFileChooserModels(sharedLinks: Results<SharedLink.RealmModel>) -> [FileChooserModel] {
        var results: [FileChooserModel] = []
        sharedLinks
            .forEach { link in
                if link.sharedAsset?.assetType == AssetType.file.rawValue {
                    let fileAsset = link.sharedAsset!.asset!.fileAsset
                    results.append(FileChooserModel(
                        resourceUri: fileAsset!.resourceURI,
                        resourceId: fileAsset!.resourceID,
                        flags: fileAsset!.entityFlat.flags,
                        name: fileAsset!.name,
                        thumbnailUrl: fileAsset!.thumbnailURL,
                        lastDateModified: fileAsset!.lastModified.toDate(),
                        isAvailableOnDevice: fileAsset?.isAvailableOnDevice == true,
                        fileType: fileAsset?.fileType
                    ))
                } else {
                    let folderAsset = link.sharedAsset!.asset!.folderAsset!.entity
                    results.append(contentsOf: getAllFiles(from: folderAsset))
                }
            }
        return results
    }
    
    func getAllFiles(from folder: VCSFolderResponse) -> [FileChooserModel] {
        var allFiles = folder.files
            .map {
                FileChooserModel(
                    resourceUri: $0.resourceURI,
                    resourceId: $0.resourceID,
                    flags: $0.flags,
                    name: $0.name,
                    thumbnailUrl: $0.thumbnailURL,
                    lastDateModified: nil,
                    isAvailableOnDevice: $0.isAvailableOnDevice,
                    fileType: $0.fileType
                )
            }
        
        for subfolder in folder.subfolders {
            allFiles.append(contentsOf: getAllFiles(from: subfolder))
        }
        
        return allFiles
        
    }
    
    private func handleError(_ error: Error) {
        if error.responseCode != VCSNetworkErrorCode.noInternet.rawValue {
            changeViewState(to: .error(error.localizedDescription))
        } else {
            changeViewState(to: .loaded)
        }
    }
}
