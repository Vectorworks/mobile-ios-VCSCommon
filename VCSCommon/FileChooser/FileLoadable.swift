import Foundation
import UIKit

protocol FileLoadable: ObservableObject, AnyObject {
    var paginationState: PaginationState { get set }
    
    var route: FileChooserRouteData { get set }
    
    var viewState: FileChooserViewState { get set }
    
    var fileTypeFilter: FileTypeFilter { get }
    
    var sharedWithMe: Bool { get }
    
    var nextPage: [String: Int] { get set }
    
    var hasMorePages: [String: Bool] { get set }
    
    func loadNextPage(silentRefresh: Bool) async
    
    func loadSampleFiles()
    
    func setupPagination()
    
    func updatePaginationWithLoadedFiles(models: [FileChooserModel])
}

extension FileLoadable {
    
    func loadNextPage(silentRefresh: Bool) async {
        DispatchQueue.main.async { [self] in
            paginationState = .loadingNextPage
            if silentRefresh {
                viewState = .loadingNextPage
            } else {
                viewState = .loading
            }
        }
        
        let filterExtensionsWithMorePages = hasMorePages
            .filter { $0.value == true }
            .map { $0.key }
        
        for ext in filterExtensionsWithMorePages {
            let query = ".\(ext)"
            
            if sharedWithMe {
                do {
                    let response = try await APIClient.searchSharedWithMe(query: query, page: nextPage[ext]!)
                    
                    updatePaginationState(hasMorePages: response.next != nil, fileType: ext)
                    
                    response.results
                        .forEach {
                            $0.asset.loadLocalFiles()
                            VCSCache.addToCache(item: $0)
                        }
                    
                    DispatchQueue.main.async { [self] in
                        viewState = .loaded
                    }
                } catch {
                    handleError(error)
                }
            } else {
                do {
                    let response = try await APIClient.search(query: query, storageType: route.storageType.rawValue, page: nextPage[ext]!)
                    
                    updatePaginationState(hasMorePages: response.next != nil, fileType: ext)
                    
                    response.results
                        .map { $0.asset }
                        .forEach {
                            $0.loadLocalFiles()
                            VCSCache.addToCache(item: $0)
                        }
                    
                    DispatchQueue.main.async { [self] in
                        viewState = .loaded
                    }
                } catch {
                    handleError(error)
                }
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
                paginationState = .hasNextPage
            }
        }
    }
    
    func loadSampleFiles() {
        viewState = .loading
        
        let sampleFilesLink = VCSServer.default.serverURLString.stringByAppendingPath(
            path: "/links/:samples/:metadata/")
        let predicate = NSPredicate(format: "RealmID = %@", sampleFilesLink)
        let cachedSampleFilesLink = SharedLink.realmStorage.getAll(predicate: predicate).first
        
        let folderAsset = cachedSampleFilesLink?.sharedAsset?.asset
        
        if cachedSampleFilesLink == nil {
            let owner = VCSUser.savedUser
            let sampleFilesSharedLink = SharedLink(
                link: sampleFilesLink, isSampleFiles: true,
                sharedAsset: cachedSampleFilesLink?.sharedAsset, owner: owner)
            VCSCache.addToCache(item: sampleFilesSharedLink, forceNilValuesUpdate: true)
            guard let folderURI = sampleFilesSharedLink.metadataURLSuffixForRequest else {
                self.viewState = .error("Error parsing sample files link \(sampleFilesSharedLink.link)")
                return
            }
            
            APIClient.linkSharedAsset(assetURI: folderURI).execute(completion: {
                (result: Result<VCSShareableLinkResponse, Error>) in
                switch result {
                case .success(let success):
                    success.asset.loadLocalFiles()
                    let updatedSampleFilesLink = SharedLink(
                        link: sampleFilesLink, isSampleFiles: true, sharedAsset: success,
                        owner: owner)
                    VCSCache.addToCache(item: updatedSampleFilesLink, forceNilValuesUpdate: true)
                    self.viewState = .loaded
                case .failure(let error):
                    self.handleError(error)
                }
            })
        } else {
            self.viewState = .loaded
        }
    }
    
    private func handleError(_ error: Error) {
        DispatchQueue.main.async { [self] in
            if error.responseCode != VCSNetworkErrorCode.noInternet.rawValue {
                viewState = .error(error.localizedDescription)
            } else {
                viewState = .loaded //offline
            }
        }
    }
}
