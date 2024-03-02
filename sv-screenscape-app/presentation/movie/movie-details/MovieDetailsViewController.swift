//
//  MovieDetailsViewController.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 02/03/2024.
//

import Kingfisher
import RxSwift
import UIKit

final class MovieDetailsViewController: BaseViewController<MovieDetailsViewModel> {
    @IBOutlet var backdropImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var runtimeLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var releaseDateLabel: UILabel!

    let viewDidAppearPublishSubject = PublishSubject<Void>()

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

extension MovieDetailsViewController {
    private func setupView() {
        backdropImageView.layer.opacity = 0.5
        backdropImageView.contentMode = .scaleAspectFill
        titleLabel.font = .systemFont(ofSize: 30, weight: .heavy)
        titleLabel.numberOfLines = 0
        titleLabel.text = ""
        runtimeLabel.font = .systemFont(ofSize: 14)
        runtimeLabel.text = ""
        runtimeLabel.textAlignment = .center
        releaseDateLabel.font = .systemFont(ofSize: 14)
        releaseDateLabel.textAlignment = .center
        releaseDateLabel.text = ""
        overviewLabel.text = ""
        overviewLabel.numberOfLines = 0
    }

    private func updateUI(_ movieDetails: MovieDetailsEntity) {
        backdropImageView.kf.setImage(with: movieDetails.imageUrl)
        titleLabel.text = movieDetails.title
        runtimeLabel.text = convertMinutesToTimeString(movieDetails.runtime)
        releaseDateLabel.text = movieDetails.releaseDate
        let overviewTitleTextAttributedText = NSAttributedString(string: "OVERVIEW\n", attributes: [.font: UIFont.systemFont(ofSize: 25, weight: .heavy), .foregroundColor: UIColor.darkGray])
        let overviewAttributedText = NSAttributedString(string: movieDetails.overview, attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor.label])
        let attributedText = NSMutableAttributedString()
        attributedText.append(overviewTitleTextAttributedText)
        attributedText.append(overviewAttributedText)
        overviewLabel.attributedText = attributedText
    }

    private func convertMinutesToTimeString(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60

        if hours == 0 {
            return "\(remainingMinutes) mins"
        } else if remainingMinutes == 0 {
            return "\(hours) hr"
        } else {
            return "\(hours) hr \(remainingMinutes) mins"
        }
    }
}

// MARK: - Subscribe

extension MovieDetailsViewController {
    private func subscribe() {
        viewDidAppearPublishSubject
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.subscribeData()
            })
            .disposed(by: disposeBag)
    }

    private func subscribeData() {
        viewModel?.fetchDataPublishSubject.onNext(())
        viewModel?
            .dataPublishSubject
            .subscribe(onNext: { [weak self] details in
                guard let self = self else { return }
                updateUI(details)
            })
            .disposed(by: disposeBag)
    }
}
