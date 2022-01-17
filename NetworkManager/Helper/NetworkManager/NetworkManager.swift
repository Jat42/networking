//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by Jat42 on 19/07/21.
//

import UIKit

public class NetworkManager: NSObject {
    
    public typealias HTTPHeader = [String:String]
    public typealias HTTPParameter = [String:Any]
    
    private static let session = URLSession.shared
    
    /// Regular api request
    /// - parameter url: Set string url
    /// - parameter method: request type
    /// - parameter header: custom header
    /// - parameter defaultHeader: default header
    /// - parameter parameter: parameter
    /// - parameter completion: completion handler for response
    static func makeNetworkRequest<E: Encodable,T: Decodable>(
        url: String,
        method: HTTPRequestMethod = .get,
        header: HTTPHeader?,
        defaultHeader: Bool = true,
        parameter: E?,
        completion: @escaping (Swift.Result<T?,Error>)-> Void
    ) {
        
        // For checking invalid or empty url
        guard let url = URL(string: url) else {
            completion(.failure(httpError.invalidUrl))
            return
        }
        
        // Create url request
        var urlRequest = NetworkManager.createRequest(url: url)
        
        // Set request method
        urlRequest.httpMethod = method.rawValue
        
        // Set header
        if defaultHeader {
            urlRequest.addValue(
                HTTPHeaderConstant.jsonContentType,
                forHTTPHeaderField: HTTPHeaderConstant.contentType
            )
            urlRequest.addValue(
                "token", // Set user authorization token
                forHTTPHeaderField: HTTPHeaderConstant.authorization
            )
        }
        
        if let httpHeader = header, !defaultHeader {
            for (key,value) in httpHeader {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Set request body
        if let param = parameter {
            urlRequest.httpBody = NetworkHelper.encodeJson(data: param)
        }
        
        // Make network call
        Network.makeNetworkCall(
            with: urlRequest,
            decodeType: T.self
        ) { response in
                
            switch response {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
    }
    
    
    /// Regular api request
    /// - parameter url: Set string url
    /// - parameter method: request type
    /// - parameter header: custom header
    /// - parameter defaultHeader: default header
    /// - parameter parameter: parameter
    /// - parameter completion: completion handler for response
    @available(iOS 15.0.0, *)
    static func makeNetworkRequest<E: Encodable,T: Decodable>(
        url: String,
        method: HTTPRequestMethod = .get,
        header: HTTPHeader?,
        defaultHeader: Bool = true,
        parameter: E?
    ) async throws -> T {
        
        // For checking invalid or empty url
        guard let url = URL(string: url) else { throw httpError.invalidUrl }
        
        // Create url request
        var urlRequest = NetworkManager.createRequest(url: url)
        
        // Set request method
        urlRequest.httpMethod = method.rawValue
        
        // Set header
        if defaultHeader {
            urlRequest.addValue(
                HTTPHeaderConstant.jsonContentType,
                forHTTPHeaderField: HTTPHeaderConstant.contentType
            )
            urlRequest.addValue(
                "token", // Set user authorization token
                forHTTPHeaderField: HTTPHeaderConstant.authorization
            )
        }
        
        if let httpHeader = header, !defaultHeader {
            for (key,value) in httpHeader {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Set request body
        if let param = parameter {
            urlRequest.httpBody = NetworkHelper.encodeJson(data: param)
        }
        
        do {
            return try await Network.makeNetworkCall(with: urlRequest, decodeType: T.self)
        } catch {
            throw error
        }
    }
    
    
    /// Method for creating a request for non multipart  request
    /// - Parameters:
    ///   - url: url for request
    ///   - timeOut: time out interval in seconds. The default timeout is 60 seconds
    /// - Returns: returns the url request object
    private static func createRequest(
        url: URL,
        timeOut: TimeInterval = 60
    ) -> URLRequest {
        
        let request = URLRequest(
            url: url,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: timeOut
        )
   
        return request
    }
    
    
    /// Multipart image upload
    /// - parameter url: Set string url
    /// - parameter method: request type
    /// - parameter header: custom header
    /// - parameter defaultHeader: default header
    /// - parameter parameter: parameter
    /// - parameter fileData: set file data
    /// - parameter completion: completion handler for response
    @available(iOS 15.0.0, *)
    static func makeNetworkRequest<T: Decodable>(
        url: String,
        method: HTTPRequestMethod = .get,
        header: HTTPHeader?,
        defaultHeader: Bool = true,
        parameter: HTTPParameter?,
        fileData: FileData
    ) async throws -> T {
        
        // For checking invalid or empty url
        guard let url = URL(string: url) else { throw httpError.invalidUrl }
        
        // Create url request
        var urlRequest = NetworkManager.createRequest(url: url)
        
        urlRequest.httpMethod = method.rawValue
        
        let bodyBoundary = "Boundary-\(UUID().uuidString)"
        
        urlRequest.setValue(
            HTTPHeaderConstant.multipartType(boundary: bodyBoundary),
            forHTTPHeaderField: HTTPHeaderConstant.contentType
        )
        
        //attachmentKey is the api parameter name for your image do ask the API developer for this
        // file name is the name which you want to give to the file
        let requestData = createRequestBody(fileData: fileData, boundary: bodyBoundary, params: parameter)
        
        urlRequest.addValue("\(requestData.count)", forHTTPHeaderField: HTTPHeaderConstant.contentType)
        
        urlRequest.httpBody = requestData
        
        do {
            return try await Network.makeNetworkCall(with: urlRequest, decodeType: T.self)
        } catch {
            throw error
        }
    }
    
  
    /// Method for creating a body for multipart request
    /// - Parameters:
    ///   - fileData: set file data
    ///   - boundary: set boundry string
    ///   - params: parameters for multipart parameter
    /// - Returns: returns the body data
    private static func createRequestBody(
        fileData: FileData,
        boundary: String,
        params: HTTPParameter?
    ) -> Data {
        
        let lineBreak = "\r\n"
        var requestBody = Data()
        
        // add params (all params are strings)
        
        if let parameters = params {
            
            for (key, value) in parameters {
                
                requestBody.append("--\(boundary)\(lineBreak)")
                
                requestBody.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak)\(lineBreak)")
                
                requestBody.append("\(value)\(lineBreak)")
            }
        }
        
        requestBody.append("--\(boundary)\(lineBreak)")
       
        requestBody.append("Content-Disposition: form-data; name=\"\(fileData.key)\"; filename=\"\(Date().timeIntervalSince1970).\(fileData.mimeType.fileExtension)\"\(lineBreak)")
        
        requestBody.append("Content-Type: \(fileData.mimeType.rawValue)\(lineBreak)\(lineBreak)") // you can change the type accordingly if you want to
        
        requestBody.append(fileData.data)
        
        requestBody.append("\(lineBreak)")
        
        return requestBody
    }
    
}

extension UIImage {
    func toData(quality: Double = 0.4) -> Data{
        //return UIImageJPEGRepresentation(self, 0.7)! as Data
        return jpegData(compressionQuality: quality)! as Data
    }
}

extension Data {
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

struct NetworkConfiguration {
    var isEncrypted: Bool
    var isActivityIndicator: Bool
}
