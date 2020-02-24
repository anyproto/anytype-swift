//
//  HomeCollectionViewCell.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import UIKit

struct HomeCollectionViewDocumentCellModel: Hashable {
    let id = UUID()
    let title: String
    let image: UIImage? = nil
    var emojiImage: String? = nil
}

final class HomeCollectionViewDocumentCell: UICollectionViewCell {
    static let reuseIdentifer = "homeCollectionViewDocumentCellReuseIdentifier"
    
    let titleLabel = UILabel()
    let emojiImage = UILabel()
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWithModel(viewModel: HomeCollectionViewDocumentCellModel) {
        titleLabel.text = viewModel.title
        imageView.image = viewModel.image
        imageView.isHidden = false
        emojiImage.isHidden = true
        
        if viewModel.emojiImage?.unicodeScalars.first?.properties.isEmoji ?? false {
            emojiImage.text = viewModel.emojiImage
            emojiImage.isHidden = false
            imageView.isHidden = true
        }
    }
}

extension HomeCollectionViewDocumentCell {
    
    private func configure() {
        titleLabel.text = "Some text"
        layer.cornerRadius = 8.0
        backgroundColor = .white
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        emojiImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(emojiImage)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0),
            imageView.heightAnchor.constraint(equalToConstant: 48),
            imageView.widthAnchor.constraint(equalToConstant: 48),
            
            emojiImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            emojiImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0),
            emojiImage.heightAnchor.constraint(equalToConstant: 48),
            emojiImage.widthAnchor.constraint(equalToConstant: 48),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16.0),
            titleLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor),
        ])
    }
}
