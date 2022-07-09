import Foundation
import CryptoKit

public struct BaiduCloudSigner {
    
    let ak: String
    let sk: String

    public init(ak: String, sk: String) {
        self.ak = ak
        self.sk = sk
    }
    
    public func sign(request: URLRequest, validateSeconds: Int = 1800) -> URLRequest {
        
        let canonicalURI = request.url!.path.uriEncodeExceptSlash()!
        
        var canonicalQueryString: String {
            
            let urLComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
            
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
        
        let hostHeader = request.url!.host!.uriEncode()!
        
        var allHeaders = request.allHTTPHeaderFields ?? [:]
        
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
        
        let canonicalRequest = "\(request.httpMethod!)\n\(canonicalURI)\n\(canonicalQueryString)\n\(canonicalHeaders)"
        
        let utcISODateFormatter = ISO8601DateFormatter()
        let dateString = utcISODateFormatter.string(from: Date())
        
        let authStringPrefix = "bce-auth-v1/\(ak)/\(dateString)/\(validateSeconds)"
    
        let signatureHEXString = authStringPrefix.hmacSha256Hex(key: sk)

        let signatureHex = canonicalRequest.hmacSha256Hex(key: signatureHEXString)
        
        let authHeader = "bce-auth-v1/\(ak)/\(dateString)/\(validateSeconds)/\(signedHeaders)/\(signatureHex)"
        
        var request = request
        
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        
        return request
    }
}

