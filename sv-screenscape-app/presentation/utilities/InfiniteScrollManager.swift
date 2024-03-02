//
//  InfiniteScrollManager.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 02/03/2024.
//

import RxCocoa
import RxSwift
import UIKit

class InfiniteScrollManager {
    private let disposeBag = DisposeBag()
    private var isLoadingMore = false
    private let threshold: CGFloat = 50

    init() { }

    /// Adds infinite scrolling functionality to the given scroll view.
    /// - Parameters:
    ///   - scrollView: The scroll view to which infinite scrolling will be added.
    ///   - action: Closure to be executed when more data needs to be loaded.
    func addInfiniteScroll(to scrollView: UIScrollView, action: @escaping () -> Void) {
        scrollView.rx.contentOffset
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] contentOffset in
                guard let self = self else { return }

                let scrollViewHeight = scrollView.frame.size.height
                let contentHeight = scrollView.contentSize.height
                let bottomInset = scrollView.contentInset.bottom
                let bottomOffsetThreshold = contentHeight + bottomInset - scrollViewHeight + self.threshold

                if contentOffset.y >= bottomOffsetThreshold && !self.isLoadingMore {
                    self.isLoadingMore = true
                    action()
                }
            })
            .disposed(by: disposeBag)
    }

    // Resets the loading state
    func reset() {
        isLoadingMore = false
    }
    
    func disableInfiniteScroll() {
        isLoadingMore = true
    }
}
