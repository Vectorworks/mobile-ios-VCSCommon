import Foundation
import Alamofire
import OAuth2
import CocoaLumberjackSwift

/// Add authentification headers from OAuthSwift to Alamofire request
open class OAuth2RetryHandler: RequestInterceptor {
    
    let loader: OAuth2DataLoader
    fileprivate var requestsToRetry: [(RetryResult) -> Void] = []
    
    init?(oauth2: OAuth2C?) {
        guard let loader = oauth2 else { return nil }
        self.loader = OAuth2DataLoader(oauth2: loader)
    }
    
    open func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard nil != loader.oauth2.accessToken else {
            completion(.success(urlRequest))
            return
        }
        
        do {
            let request = try urlRequest.signed(with: loader.oauth2)
            DDLogWarn("cURL SIGNED \(Date()):")
            DDLogWarn("\(request.cURL(pretty: false))")
            return completion(.success(request))
        } catch {
            DDLogError("Unable to sign request: \(error)")
            return completion(.failure(error))
        }
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if let response = request.task?.response as? HTTPURLResponse, 401 == response.statusCode, let req = request.request, request.error?.isRequestRetryError == false {
            var dataRequest = OAuth2DataRequest(request: req, callback: { _ in })
            
            dataRequest.context = completion
            loader.enqueue(request: dataRequest)
            loader.attemptToAuthorize() { authParams, error in
                self.loader.dequeueAndApply() { req in
                    if let comp = req.context as? (RetryResult) -> Void {
                        if error == .requestCancelled {
                            comp(.doNotRetryWithError(error!))
                        } else {
                            comp(nil != authParams ? .retry : .doNotRetry)
                        }
                    }
                }
            }
        } else {
            completion(.doNotRetry)   // not a 401, not our problem
        }
    }
}
