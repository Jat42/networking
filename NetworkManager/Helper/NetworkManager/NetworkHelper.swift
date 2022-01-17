//
//  NetworkEnums.swift
//  NetworkManager
//
//  Created by Jat42 on 19/07/21.
//

import UIKit

class NetworkHelper {
    
    
    /// Decode json data with decodable type
    /// - Returns: returns decodable type
    static func decodeJsonData<T: Decodable>(decode data: Data, with type: T.Type) -> T? {
        
        do {
            
            let type = try JSONDecoder().decode(type.self, from: data)
            return type
            
        } catch {
            
            print("\(#file)Json decoding error:- \(error)")
            return nil
        }
    }
    
    
    /// Get json string from generic encodable type
    /// - Returns: returns optional json string
    static func getJsonString<T: Encodable>(data: T) -> String? {
        
        do {
            
            let jsonData = try JSONEncoder().encode(data)
            return String(data: jsonData, encoding: .utf8)
            
        } catch {
            
            print("\(#file)Json encoding error:- \(error)")
            return nil
        }
    }
    
    
    /// Get json string from dictionary
    /// - Parameter data: pass any type to get json string
    /// - Returns: returns optional json string
    static func getJsonString(data: Any?) -> String? {
        
        guard data != nil else { return nil }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data!, options: []) else {
            return nil
        }
        
        return String(data: jsonData, encoding: String.Encoding.utf8)
    }
    
    
    /// Get encoded json data from encodable type
    /// - Returns: returns converted json data
    static func encodeJson<T: Encodable>(data: T) -> Data? {
        return try? JSONEncoder().encode(data)
    }
    
    
    /// Get json data from any type
    /// - Parameter data: pass any type to get json string
    /// - Returns: returns converted json data
    static func encodeJson(data: Any?) -> Data? {
        return try? JSONSerialization.data(withJSONObject: data!, options: [.prettyPrinted])
    }
    
}

struct HTTPHeaderConstant {
    static let authorization = "Authorization"
    static let contentType = "Content-Type"
    static let jsonContentType = "application/json"
    static let accept = "Accept"
    static let contentLength = "content-length"
    static func multipartType(boundary: String) -> String {
        return "multipart/form-data; boundary=\(boundary)"
    }
}

struct HTTPStatusCode {
    
    /// All success statusCodes
    static let success = 200...299
    
    /// Bad request
    static let badRequest = 400
    
    /// Unathorised
    static let unauthorised = 401
    
    /// Data not found
    static let notFound = 404
    
    /// All server errors and crashes
    static let internalServerError = 500...599
}

enum HTTPRequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum httpError: Error {
    
    case invalidUrl
    case serverError
    case statusCodeError
    case unauthorised
    case invalidParameter
    case missingResponseData
    case networkError
    
    var errorDescription: String? {
        
        switch self {
            case .invalidUrl:
                return HTTPErrorString.invalidUrl
            case .serverError:
                return HTTPErrorString.serverError
            case .statusCodeError:
                return HTTPErrorString.statusCodeError
            case .unauthorised:
                return HTTPErrorString.unauthorised
            case .invalidParameter:
                return HTTPErrorString.invalidParameter
            case .missingResponseData:
                return HTTPErrorString.missingResponseData
            case .networkError:
                return HTTPErrorString.networkError
                
        }
    }
    
    private struct HTTPErrorString {
        static let invalidUrl = "Please enter valid url."
        static let serverError = "Something went wrong, Please try again later."
        static let statusCodeError = "Invalid status code."
        static let unauthorised = "User unauthorised."
        static let invalidParameter = "Please enter valid parameter."
        static let missingResponseData = "Response data is missing."
        static let networkError = "Please check your Internet connection."
    }
}

enum MimeTypes: String {
    
    case jpeg = "image/jpeg"
    case jpg = "image/jpg"
    case png = "image/png"
    case pdf = "application/pdf"
    case wav = "audio/wav"
    
    var fileExtension: FileExtensions.RawValue {
        get {
            switch self {
                case .jpeg:
                    return FileExtensions.jpeg.rawValue
                case .jpg:
                    return FileExtensions.jpg.rawValue
                case .png:
                    return FileExtensions.png.rawValue
                case .pdf:
                    return FileExtensions.pdf.rawValue
                case .wav:
                    return FileExtensions.wav.rawValue
            }
        }
    }
    
    enum FileExtensions: String {
        case jpeg = "jpeg"
        case jpg = "jpg"
        case png = "png"
        case pdf = "pdf"
        case wav = "wav"
    }
}

struct FileData {
    var data: Data
    var mimeType: MimeTypes
    var key: String
}



