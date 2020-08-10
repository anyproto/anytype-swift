//
//  HomeCollectionViewCell.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import UIKit
import Combine

enum HomeStoriesModule {}

fileprivate typealias Namespace = HomeStoriesModule


class HomeCollectionViewDocumentCellModel: Hashable {
    internal init(id: String, title: String, image: UIImage?, emojiImage: String?, subscriptions: Set<AnyCancellable> = []) {
        self.id = id
        self.title = title
        self.image = image
        self.emojiImage = emojiImage
        self.subscriptions = subscriptions
    }
    
    static func == (lhs: HomeCollectionViewDocumentCellModel, rhs: HomeCollectionViewDocumentCellModel) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    let id: String
    @Published var title: String
    @Published var image: UIImage?
    @Published var emojiImage: String?
    var subscriptions: Set<AnyCancellable> = []
        
    func configured(titlePublisher: AnyPublisher<String?, Never>) {
        titlePublisher.safelyUnwrapOptionals().sink { [weak self] (value) in
            self?.title = value
        }.store(in: &self.subscriptions)
    }
    
//    func configured(imagePublisher: AnyPublisher<String, Never>) {
//        titlePublisher.sink { [weak self] (value) in
//            self?.title = value
//        }.store(in: &self.subscriptions)
//    }
    
    func configured(emojiImagePublisher: AnyPublisher<String?, Never>) {
        emojiImagePublisher.sink { [weak self] (value) in
            self?.emojiImage = value
        }.store(in: &self.subscriptions)
    }
}

final class HomeCollectionViewDocumentCell: UICollectionViewCell {
    static let reuseIdentifer = "homeCollectionViewDocumentCellReuseIdentifier"
    
    let titleLabel = UILabel()
    let emojiImage = UILabel()
    let imageView = UIImageView()
    
    var titleSubscription: AnyCancellable?
    var emojiImageSubscription: AnyCancellable?
    var imageSubscription: AnyCancellable?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func invalidateSubscriptions() {
        self.titleSubscription = nil
    }
    
    func updateWithModel(viewModel: HomeCollectionViewDocumentCellModel) {
        self.invalidateSubscriptions()
        
        titleLabel.text = viewModel.title
        imageView.image = viewModel.image
        imageView.isHidden = false
        emojiImage.isHidden = true
        
        if viewModel.emojiImage?.unicodeScalars.first?.properties.isEmoji ?? false {
            emojiImage.text = viewModel.emojiImage
            emojiImage.isHidden = false
            imageView.isHidden = true
        }
        
        /// Subsrcibe on viewModel updates
        self.titleSubscription = viewModel.$title.receive(on: RunLoop.main).sink { [weak self] (value) in
            self?.titleLabel.text = value
        }
    }
}

extension HomeCollectionViewDocumentCell {
    
    private func configure() {
        self.titleLabel.text = ""
        self.layer.cornerRadius = 8.0
        self.backgroundColor = .white
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.titleLabel)
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.imageView)
        
        self.emojiImage.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.emojiImage)
        
        let offset: CGFloat = 16.0
        let size: CGSize = .init(width: 48, height: 48)
        
        if let superview = self.imageView.superview {
            let view = self.imageView
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: offset),
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: offset),
                view.heightAnchor.constraint(equalToConstant: size.height),
                view.widthAnchor.constraint(equalToConstant: size.width),
            ]
            NSLayoutConstraint.activate(constraints)
        }
        
        if let superview = self.emojiImage.superview {
            let view = self.emojiImage
            let constraints = [
                view.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: offset),
                view.topAnchor.constraint(equalTo: superview.topAnchor, constant: offset),
                view.heightAnchor.constraint(equalToConstant: size.height),
                view.widthAnchor.constraint(equalToConstant: size.width),
            ]
            NSLayoutConstraint.activate(constraints)
        }
        
        if let superview = self.titleLabel.superview {
            let view = self.titleLabel
            let topView = self.imageView
            let constraints = [
                view.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: offset),
                view.leftAnchor.constraint(equalTo: topView.leftAnchor),
                view.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -offset),
                view.bottomAnchor.constraint(lessThanOrEqualTo: superview.bottomAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
        }
    }
}
