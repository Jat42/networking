//
//  Network.swift
//  NetworkManager
//
//  Created by Jat42 on 16/01/22.
//

import Foundation

class Network {
    
    @available(iOS 15.0.0, *)
    static func makeNetworkCall<T: Decodable>(
        with request: URLRequest,
        decodeType: T.Type
    ) async throws -> T {
        
        guard !NetworkRechability.isRechable else { throw httpError.networkError }
        
        do {
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            let httpResponse = response as? HTTPURLResponse
            
            guard let responseCode = httpResponse?.statusCode else {
                throw httpError.statusCodeError
            }
            
            if HTTPStatusCode.success ~= responseCode {
                
                return NetworkHelper.decodeJsonData(decode: data, with: T.self)!
                
            } else if HTTPStatusCode.internalServerError ~= responseCode {
                
                throw httpError.serverError
                
            } else if HTTPStatusCode.unauthorised == responseCode {
                
                throw httpError.unauthorised
                
            } else {
                
                throw httpError.missingResponseData
            }
           
        } catch {
            
            throw error
        }
    }
    
    static func makeNetworkCall<T: Decodable>(
        with request: URLRequest,
        decodeType: T.Type,
        completion: @escaping (Swift.Result<T?,Error>)-> Void
    ) {
        
        URLSession.shared.dataTask(
            with: request
        ) { data, response, error in
                
            // For checking server errors
            if let _ = error {
                completion(
                    .failure(httpError.serverError)
                )
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            
            guard let responseCode = httpResponse?.statusCode else {
                completion(.failure(httpError.statusCodeError))
                return
            }
            
            if HTTPStatusCode.internalServerError ~= responseCode {
                completion(
                    .failure(
                        httpError.serverError
                    )
                )
                return
            } else if HTTPStatusCode.unauthorised == responseCode {
                completion(
                    .failure(
                        httpError.unauthorised
                    )
                )
                return
            } else {
                
                guard data != nil else { completion(.failure(httpError.serverError)); return }
                
                completion(
                    .success(
                        NetworkHelper.decodeJsonData(
                            decode: data!,
                            with: T.self
                        )
                    )
                )
            }
            
            return
                
        }.resume()
    }
    
}
