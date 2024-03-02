//
//  BaseViewModel.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import RxSwift

class BaseViewModel {
    let disposeBag = DisposeBag()
    weak var viewController: UIViewController?
}
