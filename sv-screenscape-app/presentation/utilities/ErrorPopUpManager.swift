//
//  ErrorPopUpManager.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import RxSwift
import UIKit

class ErrorPopupManager {
    static let shared = ErrorPopupManager()

    private init() {}

    /// Displays an error popup with the provided message on the specified view controller.
    ///
    /// - Parameters:
    ///   - viewController: The view controller on which the error popup should be presented.
    ///   - message: The message to be displayed in the error popup.
    func showErrorPopup(on viewController: UIViewController, withMessage message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
}

