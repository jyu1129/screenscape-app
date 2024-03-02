//
//  FavoriteMovieListViewModel.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import RxCocoa
import RxSwift

class FavoriteMovieListViewModel: BaseViewModel {
    private let usecase: MovieUseCase

    let fetchDataPublishSubject = PublishSubject<Void>()

    // Output
    let dataBehaviorRelay: BehaviorRelay<[MovieEntity]> = .init(value: [])

    init(usecase: MovieUseCase) {
        self.usecase = usecase
        super.init()

        fetchDataPublishSubject
            .flatMapLatest { [weak self] _ -> Observable<[MovieEntity]> in
                guard let self = self, let viewController = viewController else { return .empty() }
                return usecase
                    .fetchFavoriteMovies()
                    .trackError(on: viewController.navigationController ?? viewController)
                    .trackActivity(on: viewController)
            }
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                var modifiedData = data
                // To make collection view more staggered looking
                if !modifiedData.isEmpty {
                    let customMovie = MovieEntity(id: -1, title: "", posterImageUrl: nil, isFavorite: false)
                    modifiedData.insert(customMovie, at: 1)
                }
                self.dataBehaviorRelay.accept(modifiedData)
            })
            .disposed(by: disposeBag)
    }

    func removeMovieItemFromCoreData(movieItem: MovieEntity) {
        usecase
            .removeMovieItemFromCoreData(movieItem: movieItem)
            .subscribe(onCompleted: { [weak self] in
                guard let self = self else { return }
                var currentData = self.dataBehaviorRelay.value
                if let index = currentData.firstIndex(where: { $0.id == movieItem.id }) {
                    currentData.remove(at: index)
                    self.dataBehaviorRelay.accept(currentData)
                }
            })
            .disposed(by: disposeBag)
    }
}
