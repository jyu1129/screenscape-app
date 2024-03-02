//
//  LoadingIndicator.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import RxSwift
import UIKit

class LoadingIndicatorManager {
    static let shared = LoadingIndicatorManager()

    private let loadingIndicator: UIActivityIndicatorView

    private init() {
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.color = .gray
        loadingIndicator.hidesWhenStopped = true
    }

    /// Displays a loading indicator on the specified view controller's view.
    ///
    /// - Parameters:
    ///   - viewController: The view controller on which the loading indicator should be displayed.
    func showLoadingIndicator(on viewController: UIViewController) {
        guard let view = viewController.view else {
            return
        }
        
        loadingIndicator.center = view.center
        view.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }

    /// Hides the loading indicator from the specified view controller's view.
    ///
    /// - Parameters:
    ///   - viewController: The view controller from which the loading indicator should be removed.
    func hideLoadingIndicator(on viewController: UIViewController) {
        guard let view = viewController.view else {
            return
        }
        
        loadingIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}

