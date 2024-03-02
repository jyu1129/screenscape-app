//
//  MovieDetailsViewModel.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 02/03/2024.
//

import RxCocoa
import RxSwift

class MovieDetailsViewModel: BaseViewModel {
    private let usecase: MovieUseCase
    private let movieId: Int

    let fetchDataPublishSubject = PublishSubject<Void>()

    // Output
    let dataPublishSubject: PublishSubject<MovieDetailsEntity> = .init()

    init(usecase: MovieUseCase, movieId: Int) {
        self.usecase = usecase
        self.movieId = movieId
        super.init()

        fetchDataPublishSubject
            .flatMapLatest { [weak self] _ -> Observable<MovieDetailsEntity> in
                guard let self = self, let viewController = viewController else { return .empty() }
                return usecase
                    .fetchMovie(movieId: self.movieId)
                    .trackError(on: viewController.navigationController ?? viewController)
                    .trackActivity(on: viewController)
            }
            .subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                self.dataPublishSubject.onNext(data)
            })
            .disposed(by: disposeBag)
    }
}
