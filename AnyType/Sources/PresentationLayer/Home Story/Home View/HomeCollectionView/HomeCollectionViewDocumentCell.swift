//
//  HomeCollectionViewCell.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import UIKit

struct HomeCollectionViewDocumentCellModel {
	let title: String
	let image: UIImage
}

class HomeCollectionViewDocumentCell: UICollectionViewCell {
	static let reuseIdentifer = "homeCollectionViewDocumentCellReuseIdentifier"
	
	let viewModel: HomeCollectionViewDocumentCellModel
	
	let titleLabel = UILabel()
	let imageView = UIImageView()
	
	init(viewModel: HomeCollectionViewDocumentCellModel) {
		self.viewModel = viewModel
		
		super.init(frame: .zero)
		
		configure()
	}

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeCollectionViewDocumentCell {
	
	private func configure() {
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(titleLabel)
		
		imageView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(imageView)
		
		NSLayoutConstraint.activate([
			imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
			imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0),
			imageView.heightAnchor.constraint(equalToConstant: 48),
            imageView.widthAnchor.constraint(equalToConstant: 48),
			
			titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16.0),
			titleLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor),
		])
	}
}
