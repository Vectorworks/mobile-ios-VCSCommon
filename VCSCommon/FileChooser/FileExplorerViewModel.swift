//
//  File.swift
//
//
//  Created by Veneta Todorova on 26.07.24.
//

import Foundation

class FileExplorerViewModel: ObservableObject {
    @Published var resultFolder: Result<VCSFolderResponse, Error>? = nil
    
    @Published var sortedFolders: [VCSFolderResponse] = []
    
    @Published var sortedFiles: [VCSFileResponse] = []
    
    @Published var fileTypeFilter: FileTypeFilter
    
    init(fileTypeFilter: FileTypeFilter) {
        self.fileTypeFilter = fileTypeFilter
    }
    
    func getThumbnailURL(file: VCSFileResponse) -> URL? {
        guard let thumbnailString = file.thumbnail3D == nil || file.thumbnail3D?.isEmpty == true ? file.thumbnail : file.thumbnail3D else {
            return nil
        }
        return URL(string: thumbnailString)
    }
    
    func loadFolder(resourceUri: String) {
        self.resultFolder = nil

        APIClient.folderAsset(assetURI: resourceUri).execute { (result: Result<VCSFolderResponse, Error>) in
            switch result {
            case .success(let success):
                success.loadLocalFiles()
                VCSCache.addToCache(item: success)
            case .failure(_):
                break
            }
            self.resultFolder = result
            
            do {
                let loadedFolderResponse = try self.resultFolder?.get()
                self.sortedFolders = loadedFolderResponse?.subfolders.sorted(by: { $0.name.lowercased() < $1.name.lowercased() }) ?? []
                self.sortedFiles = loadedFolderResponse?.files
                    .sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
                    .filter { file in
                        self.fileTypeFilter.extensions.map { filterExtension in
                            filterExtension.isInFile(file: file)
                        }.contains(true)
                    } ?? []
            } catch {
                print("Error retrieving the value: \(error)")
            }
            
        }
    }
}
