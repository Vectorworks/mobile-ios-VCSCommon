import Foundation

extension URLRequest {
    public func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
        
        var cURL = "curl "
        var header = ""
        var data: String = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key,value) in httpHeaders {
#if TEST_ENV || DEBUG_ENV || DEBUG
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
#else
                if key == "Authorization" {
                    header += (pretty ? "--header " : "-H ") + "\'\(key): XXX-HIDDEN-XXX\' \(newLine)"
                } else {
                    header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
                }
#endif
            }
        }
        
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
            if bodyString.count <= 5000 {
                data = "--data '\(bodyString)'"
            } else {
                data = "--data ' # large string > 5000 # '"
            }
        }
        
        cURL += method + url + header + data
        
        return cURL
    }
}
