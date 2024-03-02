//
//  MovieListViewModel.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import RxCocoa
import RxSwift

class MovieListViewModel: BaseViewModel {
    private let usecase: MovieUseCase

    let fetchDataPublishSubject = PublishSubject<Void>()
    let fetchMoreDataPublishSubject = PublishSubject<Void>()

    // Output
    let dataBehaviorRelay: BehaviorRelay<[MovieEntity]> = .init(value: [])

    private var currentPage = 1

    init(usecase: MovieUseCase) {
        self.usecase = usecase
        super.init()

        fetchDataPublishSubject
            .flatMapLatest { [weak self] _ -> Observable<[MovieEntity]> in
                guard let self = self else { return .empty() }
                self.currentPage = 1
                return fetchData(forPage: self.currentPage)
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

        fetchMoreDataPublishSubject
            .flatMapLatest { [weak self] _ -> Observable<[MovieEntity]> in
                guard let self = self else { return .empty() }
                self.currentPage += 1
                return fetchData(forPage: self.currentPage)
            }
            .subscribe(onNext: { [weak self] newData in
                guard let self = self else { return }
                var currentData = self.dataBehaviorRelay.value
                currentData.append(contentsOf: newData)
                self.dataBehaviorRelay.accept(currentData)
            })
            .disposed(by: disposeBag)
    }

    func saveMovieItemToCoreData(movieItem: MovieEntity) {
        usecase
            .saveMovieItemToCoreData(movieItem: movieItem)
            .subscribe(onCompleted: { [weak self] in
                guard let self = self else { return }
                var currentData = self.dataBehaviorRelay.value
                if let index = currentData.firstIndex(where: { $0.id == movieItem.id }) {
                    currentData[index].isFavorite = true
                    self.dataBehaviorRelay.accept(currentData)
                }
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
                    currentData[index].isFavorite = false
                    self.dataBehaviorRelay.accept(currentData)
                }
            })
            .disposed(by: disposeBag)
    }

    private func fetchData(forPage page: Int) -> Observable<[MovieEntity]> {
        guard let viewController = viewController else { return .empty() }
        return usecase.fetchData(page: page)
            .trackError(on: viewController.navigationController ?? viewController)
            .trackActivity(on: viewController)
    }
}
