//
//  StyleViewController.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


private enum Section: Hashable {
    case main
}

private struct Item: Hashable {
    let text: String
    let font: UIFont

    private let identifier = UUID()

    static let all: [Item] = [
        ("Title".localized, UIFont.header1Font),
        ("Heading".localized, UIFont.header2Font),
        ("Subheading".localized, UIFont.header3Font),
        ("Text".localized, UIFont.bodyFont)
    ].map { Item(text: $0.0, font: $0.1) }
}

private struct ListItem {
    let icon: UIImage

    static let all: [ListItem] = [
        "StyleBottomSheet/bullet",
        "StyleBottomSheet/checkbox",
        "StyleBottomSheet/numbered",
        "StyleBottomSheet/toggle"
    ].compactMap { UIImage(named: $0) }.map(ListItem.init)
}


final class StyleViewController: UIViewController {

    private lazy var styleCollectionView: UICollectionView = {
        var config = UICollectionViewCompositionalLayoutConfiguration()

        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 1
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

            return section

        }, configuration: config)

        let styleCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        styleCollectionView.translatesAutoresizingMaskIntoConstraints = false
        styleCollectionView.backgroundColor = .white
        styleCollectionView.alwaysBounceVertical = false

        return styleCollectionView
    }()

    private var styleDataSource: UICollectionViewDiffableDataSource<Section, Item>?

    private var listStackView: UIStackView = {
        let listStackView = UIStackView()
        listStackView.distribution = .fillEqually
        listStackView.axis = .horizontal
        listStackView.spacing = 8

        return listStackView
    }()

    private var otherStyleStackView: UIStackView = {
        let otherStyleStackView = UIStackView()
        otherStyleStackView.distribution = .fillEqually
        otherStyleStackView.axis = .horizontal
        otherStyleStackView.spacing = 8

        return otherStyleStackView
    }()

    private var containerStackView: UIStackView = {
        let containerStackView = UIStackView()
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.distribution = .fillProportionally
        containerStackView.axis = .vertical
        containerStackView.spacing = 16

        return containerStackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        configureStyleDataSource()
    }

    private func setupViews() {
        view.backgroundColor = .white

        containerStackView.addArrangedSubview(listStackView)
        containerStackView.addArrangedSubview(otherStyleStackView)

        view.addSubview(styleCollectionView)
        view.addSubview(containerStackView)

        setupListStackView()
        setupOtherStyleStackView()
        setupLayout()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            styleCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            styleCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            styleCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            styleCollectionView.heightAnchor.constraint(equalToConstant: 48),

            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerStackView.topAnchor.constraint(equalTo: styleCollectionView.bottomAnchor, constant: 16),
            containerStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20),
        ])
    }

    private func setupListStackView() {
        ListItem.all.forEach { item in
            let button = ButtonsFactory.roundedBorderуButton(image: item.icon)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 48).isActive = true
            listStackView.addArrangedSubview(button)
        }
    }

    private func setupOtherStyleStackView() {
        let highlightedButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/highlighted"))
        let calloutButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/callout"))
        let colorButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/color"))
        colorButton.layer.borderWidth = 0
        let moreButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/more"))
        moreButton.layer.borderWidth = 0

        let trailingStackView = UIStackView()
        let leadingDumbView = UIView()
        leadingDumbView.translatesAutoresizingMaskIntoConstraints = false
        leadingDumbView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        let trailingDumbView = UIView()
        trailingDumbView.translatesAutoresizingMaskIntoConstraints = false
        trailingDumbView.widthAnchor.constraint(equalToConstant: 1).isActive = true

        trailingStackView.distribution = .equalSpacing
        trailingStackView.addArrangedSubview(leadingDumbView)
        trailingStackView.addArrangedSubview(colorButton)
        trailingStackView.addArrangedSubview(moreButton)
        trailingStackView.addArrangedSubview(trailingDumbView)

        otherStyleStackView.addArrangedSubview(highlightedButton)
        otherStyleStackView.addArrangedSubview(calloutButton)
        otherStyleStackView.addArrangedSubview(trailingStackView)

        otherStyleStackView.arrangedSubviews.forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            view.heightAnchor.constraint(equalToConstant: 48).isActive = true
        }
    }

    private func configureStyleDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<StyleConfigurationCell, Item> { (cell, indexPath, item) in
            var content = StyleCellContentConfiguration()
            content.text = item.text
            content.font = item.font
            cell.contentConfiguration = content
        }

        styleDataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: styleCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Item.all)
        styleDataSource?.apply(snapshot, animatingDifferences: false)
    }
}
