import Foundation
import Alamofire
import OAuth2
import CocoaLumberjackSwift

/// Add authentification headers from OAuthSwift to Alamofire request
open class OAuth2RetryHandler: RequestInterceptor {
    
    public internal(set) var userDidCancelSingIn = false
    let loader: OAuth2DataLoader
    fileprivate var requestsToRetry: [(RetryResult) -> Void] = []
    private var retryCounter = 4
    private var retryClearDataBlock: () -> Void = {}
    
    init?(oauth2: OAuth2C?, retryClearDataBlock: @escaping () -> Void) {
        guard let loader = oauth2 else { return nil }
        self.loader = OAuth2DataLoader(oauth2: loader)
        self.retryClearDataBlock = retryClearDataBlock
        self.resetRetryCounter()
        
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
    
    open func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if self.userDidCancelSingIn == false, let response = request.task?.response as? HTTPURLResponse, 401 == response.statusCode || 403 == response.statusCode, let req = request.request {
            self.retryCounter = self.retryCounter - 1
            
            DDLogError("Retrying 1/3 message - \(request.request?.url)")
            DDLogError("Retrying 2/3 message - \(response.statusCode)")
            DDLogError("Retrying 3/3 message - \(error)")
            
            if self.retryCounter == 0 {
                self.retryClearDataBlock()
                self.resetRetryCounter()
            }
            
            var dataRequest = OAuth2DataRequest(request: req, callback: { _ in })
            
            dataRequest.context = completion
            loader.enqueue(request: dataRequest)
            loader.attemptToAuthorize() { authParams, error in
                self.loader.dequeueAndApply() { req in
                    if self.retryCounter > 0 {
                        if let comp = req.context as? (RetryResult) -> Void {
                            comp(nil != authParams ? .retry : .doNotRetry)
                        } else {
                            completion(.doNotRetryWithError(VCSNetworkError.parsingError("RetryResult - cannot parse req.context")))
                        }
                    } else {
                        completion(.doNotRetryWithError(VCSNetworkError.parsingError("Too many retries   ")))
                    }
                }
            }
        } else {
            completion(.doNotRetry)   // not a 401, not our problem
        }
    }
    
    public func resetRetryCounter() {
        self.retryCounter = 4
    }
}
