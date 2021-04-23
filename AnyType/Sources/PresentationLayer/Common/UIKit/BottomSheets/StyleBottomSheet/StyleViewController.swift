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
    let text: String?

    private let identifier = UUID()

    static let all: [Item] = ["Title", "Heading", "Subheading", "Text"].map { Item(text: $0) }
}

final class StyleViewController: UIViewController {

    private lazy var styleCollectionView: UICollectionView = {
        var config = UICollectionViewCompositionalLayoutConfiguration()

        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let orthogonallyScrollsBehavior = UICollectionLayoutSectionOrthogonalScrollingBehavior.groupPagingCentered

            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
//            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

            let containerGroupFractionalWidth = CGFloat(0.85)
            let containerGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(containerGroupFractionalWidth),
                                                   heightDimension: .fractionalHeight(1.0)),
                subitems: [item])

            let section = NSCollectionLayoutSection(group: containerGroup)
            section.orthogonalScrollingBehavior = orthogonallyScrollsBehavior

            return section

        }, configuration: config)

        let styleCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)

        styleCollectionView.translatesAutoresizingMaskIntoConstraints = false
        styleCollectionView.delegate = self

        return styleCollectionView
    }()

    private var styleDataSource: UICollectionViewDiffableDataSource<Section, Item>?

    private var listStackView: UIStackView = {
        let listStackView = UIStackView()
        listStackView.translatesAutoresizingMaskIntoConstraints = false
        return listStackView
    }()

    private var otherStyleStackView: UIStackView = {
        let otherStyleStackView = UIStackView()
        otherStyleStackView.translatesAutoresizingMaskIntoConstraints = false
        return otherStyleStackView
    }()

    private var containerStackView: UIStackView = {
        let containerStackView = UIStackView()
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.distribution = .fillEqually
        containerStackView.axis = .vertical
        containerStackView.spacing = 16
        containerStackView.alignment = .center

        return containerStackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        configureStyleDataSource()
    }

    private func setupViews() {
        containerStackView.addArrangedSubview(styleCollectionView)
        containerStackView.addArrangedSubview(listStackView)
        containerStackView.addArrangedSubview(otherStyleStackView)

        view.addSubview(containerStackView)

        setupLayout()
    }

    private func setupLayout() {
        containerStackView.edgesToSuperview()
    }

    private func configureStyleDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<StyleConfigurationCell, Item> { (cell, indexPath, item) in
            var content = StyleCellContentConfiguration()
            content.text = item.text
            cell.contentConfiguration = content
        }

        styleDataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: styleCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Item) -> UICollectionViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Item.all)
        styleDataSource?.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - UICollectionViewDelegate

extension StyleViewController: UICollectionViewDelegate {

}
