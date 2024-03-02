//
//  MovieDataEntity.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 02/03/2024.
//

import Foundation

struct MovieDataEntity: Decodable {
    let page: Int
    let results: [MovieItemDataEntity]
    
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case results = "results"
    }
}

struct MovieItemDataEntity: Decodable {
    let id: Int
    let title: String
    let posterPath: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case posterPath = "poster_path"
    }
}
