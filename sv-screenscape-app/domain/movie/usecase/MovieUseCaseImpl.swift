//
//  MovieUseCaseImpl.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 02/03/2024.
//

import Foundation
import RxSwift

class MovieUseCaseImpl: MovieUseCase {
    private let repository: MovieRepository
    
    init(repository: MovieRepository) {
        self.repository = repository
    }
    
    /// Fetches movie asynchronously.
    ///
    /// - Returns: An observable sequence of movie details entities.
    func fetchMovie(movieId: Int) -> Observable<MovieDetailsEntity> {
        return repository.fetchMovie(movieId: movieId)
    }
    
    /// Fetches data asynchronously.
    ///
    /// - Returns: An observable sequence of movie entities.
    func fetchData(page: Int) -> Observable<[MovieEntity]> {
        return repository.fetchData(page: page)
    }
    
    /// Saves the given movie item to Core Data.
    ///
    /// - Parameters:
    ///    - movieItem: The movie entity to be saved to Core Data.
    ///
    /// - Returns: An observable indicating the result of the operation. Emits a Void value upon successful saving.
    func saveMovieItemToCoreData(movieItem: MovieEntity) -> Observable<Void> {
        return repository.saveMovieItemToCoreData(movieItem: movieItem)
    }

    /// Removes the given movie item from Core Data.
    ///
    /// - Parameters:
    ///    - movieItem: The movie entity to be removed from Core Data.
    ///
    /// - Returns: An observable indicating the result of the operation. Emits a Void value upon successful removal.
    func removeMovieItemFromCoreData(movieItem: MovieEntity) -> Observable<Void> {
        return repository.removeMovieItemFromCoreData(movieItem: movieItem)
    }

    /// Fetches data asynchronously.
    ///
    /// - Returns: An observable sequence of favorite movie entities.
    func fetchFavoriteMovies() -> Observable<[MovieEntity]> {
        return repository.fetchFavoriteMovies()
    }
}
