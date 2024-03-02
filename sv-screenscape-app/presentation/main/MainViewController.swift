//
//  MainViewController.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import RxCocoa
import RxGesture
import RxSwift
import UIKit

class MainViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        subscribe()
    }
}

// MARK: - Setup View

extension MainViewController {
    private func setupView() {
        let firstViewController = DIContainer.resolve(MovieListViewController.self)!
        let secondViewController = DIContainer.resolve(FavoriteMovieListViewController.self)!

        firstViewController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        secondViewController.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "star.fill"), tag: 1)

        viewControllers = [firstViewController, secondViewController]
    }
}

// MARK: - Subscribe

extension MainViewController {
    private func subscribe() {
    }
}
