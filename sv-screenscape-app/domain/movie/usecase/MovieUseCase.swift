//
//  MovieUseCase.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 02/03/2024.
//

import Foundation
import RxSwift

protocol MovieUseCase {
    func fetchMovie(movieId: Int) -> Observable<MovieDetailsEntity>
    func fetchData(page: Int) -> Observable<[MovieEntity]>
    func saveMovieItemToCoreData(movieItem: MovieEntity) -> Observable<Void>
    func removeMovieItemFromCoreData(movieItem: MovieEntity) -> Observable<Void>
    func fetchFavoriteMovies() -> Observable<[MovieEntity]>
}
