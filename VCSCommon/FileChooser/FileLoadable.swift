import Foundation
import UIKit
import RealmSwift

protocol FileLoadable: ObservableObject, AnyObject {
    var paginationState: PaginationState { get set }
    
    var route: FileChooserRouteData { get set }
    
    var viewState: FileChooserViewState { get set }
    
    var fileTypeFilter: FileTypeFilter { get }
    
    var sharedWithMe: Bool { get }
    
    var nextPage: [String: Int] { get set }
    
    var hasMorePages: [String: Bool] { get set }
    
    func loadNextPage(silentRefresh: Bool) async
    
    func loadFilesForGuestMode() async
    
    func updatePaginationWithLoadedFiles(models: [FileChooserModel])
    
    func changeViewState(to viewState: FileChooserViewState)
    
    func changePaginationState(to paginationState: PaginationState)
}

extension FileLoadable {
    
    func changeViewState(to viewState: FileChooserViewState) {
        DispatchQueue.main.async { [self] in
            self.viewState = viewState
        }
    }
    
    func changePaginationState(to paginationState: PaginationState) {
        DispatchQueue.main.async { [self] in
            self.paginationState = paginationState
        }
    }
    
    func loadNextPage(silentRefresh: Bool) async {
        changePaginationState(to: .loadingNextPage)
        if silentRefresh {
            changeViewState(to: .loadingNextPage)
        } else {
            changeViewState(to: .loading)
        }
        
        let isFirstPage = nextPage.filter { $0.value > 0 }.isEmpty
        
        if isFirstPage && sharedWithMe {
            do {
                try await loadAndSaveSharedLinksContents()
            } catch {
                handleError(error)
            }
        }
        
        let filterExtensionsWithMorePages = hasMorePages
            .filter { $0.value == true }
            .map { $0.key }
        
        for ext in filterExtensionsWithMorePages {
            let query = ".\(ext)"
            
            do {
                if sharedWithMe {
                    let response = try await APIClient.searchSharedWithMe(query: query, page: nextPage[ext]!)
                    
                    updatePaginationState(hasMorePages: response.next != nil, fileType: ext)
                    
                    response.results
                        .forEach {
                            $0.asset.loadLocalFiles()
                            VCSCache.addToCache(item: $0)
                        }
                } else {
                    let response = try await APIClient.search(query: query, storageType: route.storageType.rawValue, page: nextPage[ext]!)
                    
                    updatePaginationState(hasMorePages: response.next != nil, fileType: ext)
                    
                    response.results
                        .map { $0.asset }
                        .forEach {
                            $0.loadLocalFiles()
                            VCSCache.addToCache(item: $0)
                        }
                }
                changeViewState(to: .loaded)
            } catch {
                handleError(error)
            }
        }
    }
    
    func updatePaginationWithLoadedFiles(models: [FileChooserModel]) {
        let filterExtensionsWithMorePages = hasMorePages
            .filter { $0.value == true }
            .map { $0.key }
        
        for fileExtension in filterExtensionsWithMorePages {
            let totalFilesInDatabaseCount = models
                .filter { $0.name.range(of: fileExtension, options: .caseInsensitive) != nil }
                .count
            
            let pageSize = 100
            
            let fullyLoadedPages = totalFilesInDatabaseCount / pageSize
            
            let remainingFilesOnPartialPage = totalFilesInDatabaseCount % pageSize
            
            let nextPageToRequest = remainingFilesOnPartialPage == 0 ? (fullyLoadedPages + 1) : fullyLoadedPages + 1
            
            nextPage[fileExtension] = nextPageToRequest
        }
    }
    
    
    func setupPagination() {
        let filterExtensions = fileTypeFilter.extensions.map { $0.pathExt }
        
        for ext in filterExtensions {
            nextPage[ext] = 0
            hasMorePages[ext] = true
        }
    }
    
    func updatePaginationState(hasMorePages: Bool, fileType: String) {
        DispatchQueue.main.async { [self] in
            self.nextPage[fileType] = nextPage[fileType]! + 1
            self.hasMorePages[fileType] = hasMorePages
            
            let anyTypeHasMorePages = self.hasMorePages.values.contains(true)
            if anyTypeHasMorePages {
                changePaginationState(to: .hasNextPage)
            }
        }
    }
    
    func loadFilesForGuestMode() async {
        changeViewState(to: .loading)
        
        do {
            try await loadAndSaveSharedLinksContents()
            try await loadAndSaveSampleFilesContents()
            
            changeViewState(to: .loaded)
        } catch (let error) {
            self.handleError(error)
        }
    }
    
    func loadAndSaveSharedLinksContents() async throws {
        let cachedSharedLinks = SharedLink.realmStorage.getAll(predicate: SharedWithMeViewModel.linksPredicate)
        
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
        
        let owner = VCSUser.savedUser
        
        let predicate = NSPredicate(format: "RealmID = %@", sampleFilesLink)
        let cachedSampleFilesLink = SharedLink.realmStorage.getAll(predicate: predicate).first
        
        let shouldLoadSampleFilesSubfolders = (cachedSampleFilesLink?.sharedAsset?.asset as? VCSFolderResponse)?.subfolders.filter { !$0.subfolders.isEmpty }.count == 0
        
        if shouldLoadSampleFilesSubfolders {
            let sampleFolderResponse = try await APIClient.linkSharedAssetAsync(assetURI: folderURI)
            
            sampleFolderResponse.asset.loadLocalFiles()
            
            let updatedSampleFilesLink = SharedLink(link: sampleFilesLink, isSampleFiles: true, sharedAsset: sampleFolderResponse, owner: owner)
            
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
    
    private func handleError(_ error: Error) {
        if error.responseCode != VCSNetworkErrorCode.noInternet.rawValue {
            changeViewState(to: .error(error.localizedDescription))
        } else {
            changeViewState(to: .loaded)
        }
    }
}
