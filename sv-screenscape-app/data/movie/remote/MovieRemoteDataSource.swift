//
//  MovieRemoteDataSource.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 02/03/2024.
//

import Alamofire
import CoreData
import Foundation
import RxSwift

class MovieRemoteDataSource {
    enum Endpoint {
        static let baseUrl = "https://api.themoviedb.org/3"
        static let movieDetails = "/movie"
        static let discoverMovies = "/discover/movie"
    }

    enum ParameterKey {
        static let apiKey = "api_key"
        static let includeAdult = "include_adult"
        static let includeVideo = "include_video"
        static let language = "language"
        static let page = "page"
        static let sortBy = "sort_by"
    }
    
    static func fetchMovie(movieId: Int) -> Observable<MovieDetailsEntity> {
        guard let url = constructUrl(movieId: movieId) else {
            return Observable.error(NetworkError.invalidUrl)
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.apiKey)",
            "accept": "application/json",
        ]
        
        return NetworkManager
            .shared
            .responseDecodable(url: url, headers: headers, responseType: MovieDetailsDataEntity.self)
            .map { details in
                let imageUrl = Constants.imageBaseUrl + details.backdropPath
                return MovieDetailsEntity(imageUrl: URL(string: imageUrl), title: details.title, runtime: details.runtime, overview: details.overview, releaseDate: details.releaseDate)
            }
    }

    static func fetchData(page: Int) -> Observable<[MovieEntity]> {
        guard let url = constructUrl(page: page) else {
            return Observable.error(NetworkError.invalidUrl)
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.apiKey)",
            "accept": "application/json",
        ]

        return Observable.zip(
            NetworkManager.shared.responseDecodable(url: url, headers: headers, responseType: MovieDataEntity.self),
            fetchCoreDataFavoriteMovies()
        )
        .map { remoteMovies, favoriteMovies in
            remoteMovies.results.map { item in
                let posterImageUrl = Constants.imageBaseUrlW500 + item.posterPath
                var movieEntity = MovieEntity(id: item.id, title: item.title, posterImageUrl: URL(string: posterImageUrl), isFavorite: false)

                if let favoriteMovie = favoriteMovies.first(where: { $0.movieId == String(item.id) }) {
                    movieEntity.isFavorite = true
                }

                return movieEntity
            }
        }
    }

    static func saveMovieItemToCoreData(movieItem: MovieEntity) -> Observable<Void> {
        return fetchCoreDataFavoriteMovies()
            .flatMap({ favoriteMovies -> Observable<Void> in
                if let existingMovie = favoriteMovies.first(where: { $0.movieId == String(movieItem.id) }) {
                    existingMovie.title = movieItem.title
                    existingMovie.posterImageUrl = movieItem.posterImageUrl
                } else {
                    let movieCoreDataEntity = MovieCoreDataEntity(context: managedObjectContext)
                    movieCoreDataEntity.movieId = String(movieItem.id)
                    movieCoreDataEntity.title = movieItem.title
                    movieCoreDataEntity.posterImageUrl = movieItem.posterImageUrl
                }
                try managedObjectContext.save()

                return .just(())
            })
    }

    static func removeMovieItemToCoreData(movieItem: MovieEntity) -> Observable<Void> {
        return Observable.create { observer in
            let fetchRequest: NSFetchRequest<MovieCoreDataEntity> = MovieCoreDataEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "movieId == %@", String(movieItem.id))

            do {
                let existingEntities = try managedObjectContext.fetch(fetchRequest)
                for entity in existingEntities {
                    managedObjectContext.delete(entity)
                }

                try managedObjectContext.save()
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }

            return Disposables.create()
        }
    }
    
    static func fetchFavoriteMovies() -> Observable<[MovieEntity]> {
        return fetchCoreDataFavoriteMovies()
            .map { favoriteMovies in
                favoriteMovies.map { favoriteMovie in
                    return MovieEntity(id: Int(favoriteMovie.movieId ?? "") ?? -1, title: favoriteMovie.title ?? "-", posterImageUrl: favoriteMovie.posterImageUrl, isFavorite: true)
                }
            }
    }

    private static func fetchCoreDataFavoriteMovies() -> Observable<[MovieCoreDataEntity]> {
        let fetchRequest: NSFetchRequest<MovieCoreDataEntity> = MovieCoreDataEntity.fetchRequest()

        do {
            let favoriteMovies = try managedObjectContext.fetch(fetchRequest)
            return Observable.just(favoriteMovies)
        } catch {
            return Observable.error(error)
        }
    }

    private static func constructUrl(page: Int) -> URL? {
        var components = URLComponents(string: Endpoint.baseUrl + Endpoint.discoverMovies)
        components?.queryItems = [
            URLQueryItem(name: ParameterKey.apiKey, value: Constants.apiKey),
            URLQueryItem(name: ParameterKey.includeAdult, value: "false"),
            URLQueryItem(name: ParameterKey.includeVideo, value: "false"),
            URLQueryItem(name: ParameterKey.language, value: "en-US"),
            URLQueryItem(name: ParameterKey.page, value: "\(page)"),
            URLQueryItem(name: ParameterKey.sortBy, value: "popularity.desc"),
        ]
        return components?.url
    }
    
    private static func constructUrl(movieId: Int) -> URL? {
        var components = URLComponents(string: Endpoint.baseUrl + Endpoint.movieDetails + "/\(movieId)")
        components?.queryItems = [
            URLQueryItem(name: ParameterKey.apiKey, value: Constants.apiKey)
        ]
        return components?.url
    }
}
