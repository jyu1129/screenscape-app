//
//  EmptyStateManager.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 02/03/2024.
//

import UIKit

class EmptyStateManager {
    private var collectionView: UICollectionView?
    private var emptyStateView: UIView?

    init() { }

    func addEmptyStateView(to collectionView: UICollectionView) {
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = "No items to display"
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        emptyStateView = UIView(frame: collectionView.bounds)
        emptyStateView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        emptyStateView?.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateView!.topAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView!.bottomAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView!.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView!.trailingAnchor),
        ])

        emptyStateView?.backgroundColor = .clear

        collectionView.addSubview(emptyStateView!)

        emptyStateView?.isHidden = true
    }

    func showEmptyState() {
        emptyStateView?.isHidden = false
    }

    func hideEmptyState() {
        emptyStateView?.isHidden = true
    }
}
