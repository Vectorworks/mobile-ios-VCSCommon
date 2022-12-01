import Foundation

typealias FileWithRelatedАRGS = (uploadedFile: VCSFileResponse, uploadedRelatedFiles: [VCSFileResponse])

public class Downloader {
    public static func downloadMultiple(files: [VCSFileResponse]) -> Future<[String], Error> {
        let download: (VCSFileResponse) -> Future<String, Error> = { (file) in APIClient.download(file: file) }
        return FutureWrapper.execute(download, onFiles: files)
    }
}

public struct FutureWrapperError: Error {
    public let failedErrors: Array<Error>
    public let failedFiles: Array<Any>
}

private struct FutureWrapper {
    static func execute<FileBefore, FileAfter>(_ method: @escaping ((FileBefore) -> Future<FileAfter, Error>), onFiles files: [FileBefore]) -> Future<[FileAfter], Error> {
        return Future<[FileAfter], Error> { (completion) in
            DispatchQueue.global(qos: .userInitiated).async {
                var futureFiles = [FileAfter]()
                var failedFiles = [FileBefore]()
                var failedErrors = [Error]()
                
                let group = DispatchGroup()
                files.forEach { (file) in
                    group.enter()
                    let syncSemaphore = DispatchSemaphore(value: 0)
                    
                    method(file).execute { (result) in
                        switch result {
                        case .failure(let error):
                            failedFiles.append(file)
                            failedErrors.append(error)
                            print(error)
                            // decide how to handle failure k number of files, 0 < k < filesToUpload.count -GKK
                            if (failedFiles.count + futureFiles.count == files.count) {
                                group.notify(queue: .main) {
                                    completion(.failure(FutureWrapperError(failedErrors: failedErrors, failedFiles: failedFiles)))
                                }
                            }
                        case .success(let future):
                            futureFiles.append(future)
                            if (failedFiles.count + futureFiles.count == files.count) {
                                group.notify(queue: .main) {
                                    completion(.success(futureFiles))
                                }
                            }
                        }
                        group.leave()
                        syncSemaphore.signal()
                    }
                    
                    syncSemaphore.wait()
                }
            }
        }
    }
}
