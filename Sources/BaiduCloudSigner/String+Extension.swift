//
//  File.swift
//  
//
//  Created by kevinzhow on 2022/7/9.
//

import Foundation
import CryptoKit

extension String {
    public func stringByAddingPercentEncodingForFormData(plusForSpace: Bool=false) -> String? {
        let unreserved = "*-._"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        
        if plusForSpace {
            allowed.addCharacters(in: " ")
        }
        
        var encoded = addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
        if plusForSpace {
            encoded = encoded?.replacingOccurrences(of: " ", with: "+")
        }
        return encoded
    }
    
    public func hmacSha256Hex(key: String) -> String {
        let key = SymmetricKey(data: key.data(using: .utf8)!)
        let signingKey = HMAC<SHA256>.authenticationCode(for: self.data(using: .utf8)!, using: key)
        
        return Data(signingKey).map { String(format: "%02hhx", $0) }.joined().lowercased()
    }
}


extension String {
    //RFC3986
    public func uriEncode() -> String? {
        let unreserved = "-._~"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
    
    public func uriEncodeExceptSlash() -> String? {
        let unreserved = "-._~/"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}
