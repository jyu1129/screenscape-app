//
//  FavoriteMovieListViewController.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import RxCocoa
import RxGesture
import RxSwift
import UIKit

class FavoriteMovieListViewController: BaseViewController<FavoriteMovieListViewModel> {
    @IBOutlet var collectionView: UICollectionView!

    let viewDidAppearPublishSubject = PublishSubject<Void>()
    let numberOfColumns = 2
    let cellPadding: CGFloat = 6.0
    var cellHeights: [IndexPath: CGFloat] = [:]
    let horizontalContentInset: CGFloat = 15.0
    let pullToRefreshManager = PullToRefreshManager()
    let emptyStateManager = EmptyStateManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        subscribe()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearPublishSubject.onNext(())
    }
}

// MARK: - Setup View

extension FavoriteMovieListViewController {
    private func setupView() {
        let pinterestLayout = PinterestLayout()

        pinterestLayout.numberOfColumns = numberOfColumns
        pinterestLayout.cellPadding = cellPadding
        pinterestLayout.delegate = self

        collectionView.collectionViewLayout = pinterestLayout
        collectionView.contentInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        collectionView.register(UINib(nibName: "MovieItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FavoriteMovieItemCollectionViewCell")
        pullToRefreshManager.addPullToRefresh(to: collectionView) { [weak self] in
            guard let self = self else { return }
            self.refreshData()
        }
        emptyStateManager.addEmptyStateView(to: collectionView)
    }
}

// MARK: - Subscribe

extension FavoriteMovieListViewController {
    private func subscribe() {
        viewDidAppearPublishSubject
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.subscribeData()
            })
            .disposed(by: disposeBag)
    }

    private func refreshData() {
        viewModel?
            .fetchDataPublishSubject
            .onNext(())
    }

    private func subscribeData() {
        refreshData()

        viewModel?
            .dataBehaviorRelay
            .asObservable()
            .bind(to: collectionView.rx.items) { [weak self] _, row, item in
                guard let self = self else { return UICollectionViewCell() }
                let indexPath = IndexPath(row: row, section: 0)

                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteMovieItemCollectionViewCell", for: indexPath) as? MovieItemCollectionViewCell else { return UICollectionViewCell() }

                cell
                    .bindMoreButtonTap { [weak self] in
                        guard let self = self else { return }
                        let bottomSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

                        bottomSheet.addAction(UIAlertAction(title: "Unfavorite", style: .default, handler: { [weak self] _ in
                            guard let self = self else { return }
                            self.viewModel?.removeMovieItemFromCoreData(movieItem: item)
                        }))

                        bottomSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                        self.present(bottomSheet, animated: true, completion: nil)
                    }
                
                cell.bindImageViewTap { [weak self] in
                    guard let self = self else { return }
                    let vc = DIContainer.resolve(MovieDetailsViewController.self, argument: item.id)!
                    vc.modalPresentationStyle = .overCurrentContext
                    let navigationController = UINavigationController(rootViewController: vc)
                    self.present(navigationController, animated: true, completion: nil)
                }

//                cell.configure(with: item)
//                
//                return cell
                
                let contentInsets = horizontalContentInset * 2
                let totalPadding = cellPadding * CGFloat(numberOfColumns - 1)
                let columnWidth = (collectionView.frame.width - totalPadding - contentInsets) / CGFloat(numberOfColumns)
                if self.cellHeights[indexPath] != nil {
                    cell.configure(with: item, isPlaceHolder: item.id == -1, width: columnWidth, completion: { _ in })
                    return cell
                } else {
                    cell.configure(with: item, isPlaceHolder: item.id == -1, width: columnWidth, completion: { [weak self] height in
                        guard let self = self else { return }
                        self.cellHeights[indexPath] = height
                        self.collectionView.reloadData()
                    })

                    return cell
                }
            }
            .disposed(by: disposeBag)

        viewModel?
            .dataBehaviorRelay
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                if data.isEmpty {
                    self.emptyStateManager.showEmptyState()
                } else {
                    self.emptyStateManager.hideEmptyState()
                    self.pullToRefreshManager.reset()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension FavoriteMovieListViewController: PinterestLayoutDelegate {
    // MARK: - PinterestLayoutDelegate

    func collectionView(collectionView: UICollectionView, heightForItemAt indexPath: IndexPath, with width: CGFloat) -> CGFloat {
        if let cachedHeight = cellHeights[indexPath] {
            return cachedHeight
        } else {
            return CGFloat.random(in: 150 ... 500)
        }
        
//        return CGFloat.random(in: 150 ... 500)
    }
}
