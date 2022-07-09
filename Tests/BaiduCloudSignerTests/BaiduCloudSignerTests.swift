import XCTest
@testable import BaiduCloudSigner

final class BaiduCloudSignerTests: XCTestCase {
    func testExample() async throws {
        
        guard let ak = Environment.get("AK"), let sk = Environment.get("SK") else {
            fatalError("Missing AK SK")
        }
        
        let signer = BaiduCloudSigner(ak: ak, sk: sk)
        
        let imageFileBase64 = try Data(contentsOf: Bundle.module.url(forResource: "testing", withExtension: "png")!).base64EncodedString().stringByAddingPercentEncodingForFormData(plusForSpace: true)!
        
        let url = URL(string: "https://aip.baidubce.com/rest/2.0/ocr/v1/general_basic")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.httpBody = "image=\(imageFileBase64)&language_type=JAP&paragraph=true&detect_direction=true".data(using: .utf8)!
        
        let signedRequest = signer.sign(request: request)
        
        let session = URLSession.shared
        
        let (data, _) = try await session.data(for: signedRequest)
        
        print(String(data: data, encoding: .utf8)!)
    }
}

