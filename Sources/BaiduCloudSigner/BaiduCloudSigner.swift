import Foundation
import CryptoKit

public struct BaiduCloudSigner {
    
    /// Access Key ID
    let ak: String
    /// Secret Access Key
    let sk: String

    /// Init `BaiduCloudSigner`
    ///
    /// - Parameters:
    ///   - ak: Access Key ID
    ///   - sk: Secret Access Key
    public init(ak: String, sk: String) {
        self.ak = ak
        self.sk = sk
    }
    
    /// Returns Signed Request
    public func sign(request: URLRequest, validateSeconds: Int = 1800) -> URLRequest {
        let authHeader = sign(method: request.httpMethod!, url: request.url!, headers: request.allHTTPHeaderFields ?? [:], validateSeconds: validateSeconds)
        
        var request = request
        
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    /// Returns Signed Authorization Header Value
    public func sign(method: String, url: URL, headers: [String : String], validateSeconds: Int = 1800) -> String {
        
        let canonicalURI = url.path.uriEncodeExceptSlash()!
        
        var canonicalQueryString: String {
            
            let urLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
            
            if let queryItems = urLComponents?.queryItems {
                let items = queryItems.sorted { q1, q2 in
                    q1.name < q2.name
                }
                
                var itemStrings: [String] = []
                
                items.forEach({ q in
                    if q.name == "authorization" {
                        // Skip
                    } else if let qValue = q.value {
                        itemStrings.append("\(q.name.uriEncode()!)=\(qValue.uriEncode()!)")
                    } else {
                        itemStrings.append("\(q.name.uriEncode()!)")
                    }
                })
                
                return itemStrings.joined(separator: "&")
            } else {
                return ""
            }
        }
        
        let hostHeader = url.host!.uriEncode()!
        
        var allHeaders = headers
        
        allHeaders["host"] = hostHeader
        
        let signedHeaders = allHeaders.compactMap({ $0.key.lowercased() }).sorted { s1, s2 in
            s1 < s2
        }.joined(separator: ";")
        
        var canonicalHeaders: String {
            
            let itemStrings = allHeaders.compactMap({ "\($0.key.lowercased().uriEncode()!):\($0.value.uriEncode()!)" }).sorted { s1, s2 in
                s1 < s2
            }
            
            return itemStrings.joined(separator: "\n")
        }
        
        let canonicalRequest = "\(method)\n\(canonicalURI)\n\(canonicalQueryString)\n\(canonicalHeaders)"
        
        let utcISODateFormatter = ISO8601DateFormatter()
        
        let dateString = utcISODateFormatter.string(from: Date())
        
        let authStringPrefix = "bce-auth-v1/\(ak)/\(dateString)/\(validateSeconds)"
    
        let signatureHEXString = authStringPrefix.hmacSha256Hex(key: sk)

        let signatureHex = canonicalRequest.hmacSha256Hex(key: signatureHEXString)
        
        let authHeader = "bce-auth-v1/\(ak)/\(dateString)/\(validateSeconds)/\(signedHeaders)/\(signatureHex)"
        
        return authHeader
    }
}

