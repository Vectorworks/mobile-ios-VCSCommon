//
//  File.swift
//
//
//  Created by Veneta Todorova on 26.07.24.
//

import Foundation

class FileExplorerViewModel: ObservableObject {
    @Published var resultFolder: Result<VCSFolderResponse, Error>? = nil
    
    @Published var currentFolder: VCSFolderResponse? = nil
    
    @Published var fileTypeFilter: FileTypeFilter
    
    var currentFolderResourceUri: String
    
    var sortedFolders: [VCSFolderResponse] {
        currentFolder?.subfolders.sorted(by: { $0.name.lowercased() < $1.name.lowercased() }) ?? []
    }
    
    var sortedFiles: [VCSFileResponse] {
        currentFolder?.files
            .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
            .filter { file in
                fileTypeFilter.extensions.map { filterExtension in
                    filterExtension.isInFile(file: file)
                }.contains(true)
            } ?? []
    }
    
    init(fileTypeFilter: FileTypeFilter, currentFolderResourceUri: String) {
        self.fileTypeFilter = fileTypeFilter
        self.currentFolderResourceUri = currentFolderResourceUri
    }
    
    func getThumbnailURL(file: VCSFileResponse) -> URL? {
        guard let thumbnailString = file.thumbnail3D == nil || file.thumbnail3D?.isEmpty == true ? file.thumbnail : file.thumbnail3D else {
            return nil
        }
        return URL(string: thumbnailString)
    }
    
    func loadFolder() {
        guard currentFolderResourceUri.isEmpty == false else {
            resultFolder = .failure(VCSError.GenericException("resourceURI is nil"))
            return
        }
        
        APIClient.folderAsset(assetURI: currentFolderResourceUri).execute { (result: Result<VCSFolderResponse, Error>) in
            switch result {
            case .success(let success):
                success.loadLocalFiles()
                VCSCache.addToCache(item: success)
            case .failure(_):
                break
            }
            self.resultFolder = result
            
            do {
                self.currentFolder = try self.resultFolder?.get()
            } catch {
                print("Error retrieving the value: \(error)")
            }
        }
    }
}
