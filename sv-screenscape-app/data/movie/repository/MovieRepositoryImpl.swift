//
//  MovieRepositoryImpl.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 02/03/2024.
//

import Foundation
import RxSwift

class MovieRepositoryImpl: MovieRepository {
    
    func fetchMovie(movieId: Int) -> Observable<MovieDetailsEntity> {
        return MovieRemoteDataSource.fetchMovie(movieId: movieId)
    }
    
    func fetchData(page: Int) -> Observable<[MovieEntity]> {
        return MovieRemoteDataSource.fetchData(page: page)
    }
    
    func saveMovieItemToCoreData(movieItem: MovieEntity) -> Observable<Void> {
        return MovieRemoteDataSource.saveMovieItemToCoreData(movieItem: movieItem)
    }
    
    func removeMovieItemFromCoreData(movieItem: MovieEntity) -> Observable<Void> {
        return MovieRemoteDataSource.removeMovieItemToCoreData(movieItem: movieItem)
    }
    
    func fetchFavoriteMovies() -> Observable<[MovieEntity]> {
        return MovieRemoteDataSource.fetchFavoriteMovies()
    }
}
