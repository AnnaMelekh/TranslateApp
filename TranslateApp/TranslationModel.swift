//
//  NetworkModel.swift
//  TranslateApp
//
//  Created by Anna Melekhina on 30.03.2025.
//

import Foundation

struct TranslationResponse: Codable {
    let sourceLanguage: String
    let sourceText: String
    let destinationLanguage: String
    let destinationText: String
    
    enum CodingKeys: String, CodingKey {
        case sourceLanguage = "source-language"
        case sourceText = "source-text"
        case destinationLanguage = "destination-language"
        case destinationText = "destination-text"
    }
}

struct TranslationParameters {
    let sourceLanguage: String?
    let destinationLanguage: String
    let text: String
    
    func toQueryItems() -> [URLQueryItem] {
        var items = [URLQueryItem]()
        
        if let sl = sourceLanguage {
            items.append(URLQueryItem(name: "sl", value: sl))
        }
        items.append(URLQueryItem(name: "dl", value: destinationLanguage))
        items.append(URLQueryItem(name: "text", value: text))
        
        return items
    }
}
