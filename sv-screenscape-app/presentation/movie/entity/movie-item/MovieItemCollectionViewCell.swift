//
//  MovieItemCollectionViewCell.swift
//  sv-screenscape-app
//
//  Created by Poh Shun Yu on 01/03/2024.
//

import Kingfisher
import RxSwift
import UIKit

class MovieItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var moreButton: UIButton!
    @IBOutlet var titleLabel: UILabel!

    var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        refreshLayout()
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        refreshLayout()
        contentView.layoutIfNeeded()
        disposeBag = DisposeBag()
    }
    
    private func refreshLayout() {
        posterImageView.image = nil
        posterImageView.backgroundColor = .lightGray
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.layer.cornerRadius = 20
        posterImageView.clipsToBounds = true
        posterImageView.isHidden = false
        moreButton.isHidden = true
        moreButton.tintColor = .label
        moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreButton.setTitle("", for: .normal)
        titleLabel.text = ""
        titleLabel.isHidden = true
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.font = .systemFont(ofSize: 14)
    }
    
    /// Configures the cell with the provided movie entity.
    ///
    /// - Parameters:
    ///   - item: The movie entity to configure the cell with. Defaults to nil.
    func configure(with item: MovieEntity) {
        titleLabel.text = item.title
        moreButton.isHidden = false
        titleLabel.isHidden = item.title.isEmpty
        posterImageView.kf.setImage(with: item.posterImageUrl)
    }

    /// Configures the cell with the provided movie entity.
    ///
    /// - Parameters:
    ///   - item: The movie entity to configure the cell with. Defaults to nil.
    ///   - isPlaceHolder: To make the pinterest-style collection view more staggered look.
    ///   - width: The width of the cell. Defaults to nil.
    ///   - completion: A closure to be called when the configuration is complete. It passes the calculated total height of the cell. Defaults to nil.
    func configure(with item: MovieEntity, isPlaceHolder: Bool = false, width: CGFloat? = nil, completion: ((CGFloat) -> Void)? = nil) {
        titleLabel.text = item.title
        if isPlaceHolder {
            posterImageView.isHidden = true
            completion?(150)
            return
        }
        guard let width = width, completion != nil else { return }
        posterImageView.kf.setImage(with: item.posterImageUrl) { [weak self] result in
            guard let self = self else { return }
            moreButton.isHidden = false
            titleLabel.isHidden = item.title.isEmpty
            self.contentView.layoutIfNeeded()
            switch result {
            case let .success(value):
                let imageWidth = value.image.size.width
                let aspectRatio = imageWidth != 0 ? width / imageWidth : 1.0
                let imageHeight = value.image.size.height * aspectRatio
                let moreButtonHeight = self.moreButton.frame.height
                let labelSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
                let labelHeight = self.titleLabel.sizeThatFits(labelSize).height
                let totalHeight = imageHeight + max(labelHeight, moreButtonHeight)

                completion?(totalHeight)
            case .failure:
                completion?(0)
            }
        }
    }

    func bindMoreButtonTap(withAction action: @escaping () -> Void) {
        moreButton
            .rx
            .tap
            .take(until: rx.deallocated) // Dispose when cell is deallocated
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                action()
            })
            .disposed(by: disposeBag)
    }
    
    func bindImageViewTap(withAction action: @escaping () -> Void) {
        posterImageView
            .rx
            .tapGesture()
            .when(.recognized)
            .take(until: rx.deallocated) // Dispose when cell is deallocated
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                action()
            })
            .disposed(by: disposeBag)
    }
}
