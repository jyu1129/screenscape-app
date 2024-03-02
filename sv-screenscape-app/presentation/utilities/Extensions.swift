//
//  Extensions.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import RxSwift
import UIKit

extension UIApplication {
    /// Retrieves the topmost view controller in the hierarchy.
    ///
    /// - Returns: The topmost view controller.
    class func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }

        var topViewController: UIViewController?

        windowScene.windows.forEach { window in
            if let rootViewController = window.rootViewController {
                topViewController = findTopViewController(from: rootViewController)
            }
        }

        return topViewController
    }

    private class func findTopViewController(from viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return findTopViewController(from: presentedViewController)
        }
        if let navigationController = viewController as? UINavigationController {
            return findTopViewController(from: navigationController.visibleViewController!)
        }
        if let tabBarController = viewController as? UITabBarController {
            return findTopViewController(from: tabBarController.selectedViewController!)
        }
        return viewController
    }
}

extension Observable {
    /// Tracks activity on a view controller by showing a loading indicator.
    ///
    /// - Parameters:
    ///     - viewController: The view controller on which to display the loading indicator.
    /// - Returns: An observable sequence that emits elements identical to the source sequence.
    func trackActivity(on viewController: UIViewController) -> Observable<Element> {
        return Observable.deferred {
            let activityIndicator = LoadingIndicatorManager.shared
            activityIndicator.showLoadingIndicator(on: viewController)

            return self.do(onNext: { _ in
                activityIndicator.hideLoadingIndicator(on: viewController)
            }, onError: { _ in
                activityIndicator.hideLoadingIndicator(on: viewController)
            }, onCompleted: {
                activityIndicator.hideLoadingIndicator(on: viewController)
            }, onDispose: {
                activityIndicator.hideLoadingIndicator(on: viewController)
            })
        }
    }

    /// Tracks errors on a view controller by showing an error popup.
    ///
    /// - Parameters:
    ///     - viewController: The view controller on which to display the error popup.
    /// - Returns: An observable sequence that emits elements identical to the source sequence.
    func trackError(on viewController: UIViewController) -> Observable<Element> {
        return self
            .catch { error in
                ErrorPopupManager.shared.showErrorPopup(on: viewController, withMessage: error.localizedDescription)
                return Observable.error(error)
            }
    }
}

extension UIView {
    /// Adds a shadow to the view with custom parameters.
    ///
    /// - Parameters:
    ///   - color: The color of the shadow. Default is black.
    ///   - opacity: The opacity of the shadow. Default is 0.5.
    ///   - offset: The offset of the shadow. Default is (0, 2).
    ///   - radius: The radius of the shadow. Default is 4.
    func addShadow(color: UIColor = .black, opacity: Float = 0.5, offset: CGSize = CGSize(width: 0, height: 2), radius: CGFloat = 4) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }
}

extension DispatchQueue {
    /// Executes a closure on a background thread after a specified delay.
    ///
    /// - Parameters:
    ///   - delay: The delay before executing the closure. Default is 0.0.
    ///   - qos: The quality of service for the background thread. Default is `.background`.
    ///   - closure: The closure to be executed.
    static func background(delay: Double = 0.0, qos: DispatchQoS.QoSClass = .background, _ closure: @escaping () -> Void) {
        DispatchQueue.global(qos: qos).asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }

    /// Executes a closure on the main thread after a specified delay.
    ///
    /// - Parameters:
    ///   - delay: The delay before executing the closure. Default is 0.0.
    ///   - qos: The quality of service for the main thread. Default is `.default`.
    ///   - closure: The closure to be executed.
    static func main(delay: Double = 0.0, qos: DispatchQoS.QoSClass = .default, _ closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            closure()
        }
    }
}
