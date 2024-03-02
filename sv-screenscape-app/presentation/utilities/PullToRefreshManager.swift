//
//  PullToRefreshManager.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 02/03/2024.
//

import UIKit

class PullToRefreshManager {
    private var refreshAction: (() -> Void)?
    private let refreshControl = UIRefreshControl()
    private weak var scrollView: UIScrollView?

    init() {}

    /// Adds pull-to-refresh functionality to the specified UIScrollView.
    ///
    /// - Parameters:
    ///   - scrollView: The UIScrollView to which pull-to-refresh functionality will be added.
    ///   - action: The action to be performed when pull-to-refresh is triggered.
    func addPullToRefresh(to scrollView: UIScrollView, action: @escaping () -> Void) {
        self.scrollView = scrollView
        self.refreshAction = action
        
        refreshControl.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }

    /// Action triggered when the refresh control value changes.
    @objc private func refreshControlValueChanged() {
        refreshAction?()
    }

    /// Ends refreshing state
    func reset() {
        DispatchQueue.main.async {
            self.scrollView?.refreshControl?.endRefreshing()
        }
    }
}

