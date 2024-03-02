//
//  BaseViewController.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import UIKit
import RxSwift

class BaseViewController<ViewModel>: UIViewController {
    let disposeBag = DisposeBag()
    var viewModel: ViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel as? BaseViewModel else { return }
        viewModel.viewController = self
    }
}
