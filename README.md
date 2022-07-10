# BaiduCloudSigner

对应 [V1](https://cloud.baidu.com/doc/Reference/s/njwvz1yfu#%E7%9B%B8%E5%85%B3%E5%87%BD%E6%95%B0%E8%AF%B4%E6%98%8E) 签名方式

## Installation

### Swift Package Manager

dependencies: [
    .package(url: "https://github.com/kevinzhow/baiducloudsigner-swift.git", .upToNextMajor(from: "0.0.1"))
]

## Usage

OCR example, please ref to `BaiduCloudSignerTests` for full code.

### Sign Request

```swift
let signer = BaiduCloudSigner(ak: "", sk: "")

let url = URL(string: "https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic")!

var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
request.httpBody = "image=\(imageFileBase64)&language_type=JAP&paragraph=true&detect_direction=true".data(using: .utf8)!

let signedRequest = signer.sign(request: request)

let session = URLSession.shared

let (data, _) = try await session.data(for: signedRequest)
```

### Get Signed Authorization Header

This is the underlying implements of `Sign Request`

```swift
let method = "POST"

let url = URL(string: "https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic")!

var headers = ["Content-Type": "application/x-www-form-urlencoded"]

let signer = BaiduCloudSigner(ak: "", sk: "")

let authHeader = signer.sign(method: method, url: url, headers: headers)
headers["Authorization"] = authHeader
```
