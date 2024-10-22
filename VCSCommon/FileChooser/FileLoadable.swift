import Foundation
import UIKit

protocol FileLoadable: AnyObject {
    var viewState: ViewState { get set }
    var fileTypeFilter: FileTypeFilter { get }
    var sharedWithMe: Bool { get }
    
    func loadFilesWithCurrentFilter(storageType: String?) async
    func loadSampleFiles()
}

extension FileLoadable {
    func loadFilesWithCurrentFilter(storageType: String?) async {
        DispatchQueue.main.async { [self] in
            viewState = .loading
        }
        
        let filterExtensions = fileTypeFilter.extensions.map { $0.pathExt }
        
        for ext in filterExtensions {
            let query = ".\(ext)"
            
            if sharedWithMe {
                do {
                    let response = try await APIClient.searchSharedWithMe(query: query)
                    let assets = response.results
                    assets.forEach {
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
                    let response = try await APIClient.search(query: query, storageType: storageType!)
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
    
    func loadSampleFiles() {
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
            if error.responseCode == VCSNetworkErrorCode.noInternet.rawValue {
                viewState = .offline
            } else {
                viewState = .error(error.localizedDescription)
            }
        }
    }
}
