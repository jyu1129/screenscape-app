//
//  MovieSetupDI.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import Swinject

class MovieSetupDI {
    static func setupDI(container: Container) {
        setupData(container: container)
        setupDomain(container: container)
        setupPresentation(container: container)
    }

    static func setupData(container: Container) {
        container.register(MovieRepository.self) { _ in
            MovieRepositoryImpl()
        }
    }

    static func setupDomain(container: Container) {
        container.register(MovieUseCase.self) { resolver in
            MovieUseCaseImpl(repository: resolver.resolve(MovieRepository.self)!)
        }
    }

    static func setupPresentation(container: Container) {
        // Movie list
        container.register(MovieListViewModel.self) { resolver in
            MovieListViewModel(usecase: resolver.resolve(MovieUseCase.self)!)
        }

        container.register(MovieListViewController.self) { resolver in
            let storyboard = UIStoryboard(name: "Movie", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "MovieListViewController") as! MovieListViewController
            viewController.viewModel = resolver.resolve(MovieListViewModel.self)!
            return viewController
        }

        // Favorite Movie list
        container.register(FavoriteMovieListViewModel.self) { resolver in
            FavoriteMovieListViewModel(usecase: resolver.resolve(MovieUseCase.self)!)
        }

        container.register(FavoriteMovieListViewController.self) { resolver in
            let storyboard = UIStoryboard(name: "Movie", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "FavoriteMovieListViewController") as! FavoriteMovieListViewController
            viewController.viewModel = resolver.resolve(FavoriteMovieListViewModel.self)!
            return viewController
        }

        // Movie details
        container.register(MovieDetailsViewModel.self) { resolver, movieId in
            MovieDetailsViewModel(usecase: resolver.resolve(MovieUseCase.self)!, movieId: movieId)
        }

        container.register(MovieDetailsViewController.self) { (resolver, movieId: Int) in
            let storyboard = UIStoryboard(name: "Movie", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "MovieDetailsViewController") as! MovieDetailsViewController
            viewController.viewModel = resolver.resolve(MovieDetailsViewModel.self, argument: movieId)!
            return viewController
        }

        // Movie item
        container.register(MovieItemCollectionViewCell.self) { _ in
            UINib(nibName: "MovieItemCollectionViewCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! MovieItemCollectionViewCell
        }
    }
}
