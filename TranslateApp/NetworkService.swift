//
//  NetworkService.swift
//  TranslateApp
//
//  Created by Anna Melekhina on 30.03.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func translate(parameters: TranslationParameters, completion: @escaping (Result<TranslationResponse, NetworkError>) -> Void)
}

enum NetworkError: Error {
    case badURL
    case badResponse
    case invalidData
    case decodeError
}



final class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://ftapi.pythonanywhere.com"
    
    func translate(parameters: TranslationParameters, completion: @escaping (Result<TranslationResponse, NetworkError>) -> Void) {
        guard var components = URLComponents(string: "\(baseURL)/translate") else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        components.queryItems = parameters.toQueryItems()
        
        guard let url = components.url else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = error {
                completion(.failure(NetworkError.badResponse))
                return
            }
            
            guard let data else {
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(TranslationResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(NetworkError.decodeError))
            }
        }.resume()
    }
}
