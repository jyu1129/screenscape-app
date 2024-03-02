//
//  MovieDetailsDataEntity.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 02/03/2024.
//

import Foundation

struct MovieDetailsDataEntity: Decodable {
    let backdropPath: String
    let title: String
    let runtime: Int
    let overview: String
    let releaseDate: String
    
    enum CodingKeys: String, CodingKey {
        case backdropPath = "backdrop_path"
        case title = "title"
        case runtime = "runtime"
        case overview = "overview"
        case releaseDate = "release_date"
    }
}
