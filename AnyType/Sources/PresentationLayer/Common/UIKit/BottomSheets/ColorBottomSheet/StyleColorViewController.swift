//
//  StyleColorViewController.swift
//  AnyType
//
//  Created by Denis Batvinkin on 26.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit


private enum SectionKind: Int, CaseIterable {
    case main
    case last

    var columnCount: Int  {
        switch self {
        case .main:
            return 6
        case .last:
            return ColorItem.all.count % 6
        }
    }
}

private struct ColorItem: Hashable {
    let color: UIColor

    private let identifier = UUID()

    static let all: [ColorItem] = [
        UIColor.grayscale90, UIColor.grayscale50, UIColor.pureLemon,
        UIColor.pureAmber, UIColor.pureRed, UIColor.purePink,
        UIColor.purePurple, UIColor.pureUltramarine, UIColor.pureBlue,
        UIColor.pureTeal, UIColor.darkGreen
    ].map { ColorItem.init(color: $0) }

    static let backgroundItems: [ColorItem] = [
        UIColor.grayscaleWhite, UIColor.lightColdgray, UIColor.lightLemon,
        UIColor.lightAmber, UIColor.lightRed, UIColor.lightPink,
        UIColor.lightPurple, UIColor.lightUltramarine, UIColor.lightBlue,
        UIColor.lightTeal, UIColor.lightGreen
    ].map { ColorItem.init(color: $0) }
}


final class StyleColorViewController: UIViewController {

    // MARK: - Viwes

    private lazy var styleCollectionView: UICollectionView = {
        var config = UICollectionViewCompositionalLayoutConfiguration()

        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            guard let sectionKind = SectionKind(rawValue: sectionIndex) else { return nil }
            let columns = sectionKind.columnCount
            let itemDimension: CGSize = .init(width: 52.0, height: 52.0)


            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemDimension.width), heightDimension: .absolute(itemDimension.height))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(52.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            group.interItemSpacing = .fixed(0)

            let section = NSCollectionLayoutSection(group: group)

            if sectionKind == .last {
                // space for leading and trailing edge
                let edgeSpacing: CGFloat = CGFloat((SectionKind.main.columnCount - columns) * (Int(itemDimension.width) / 2))
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: edgeSpacing, bottom: 0, trailing: edgeSpacing)
            }

            return section

        }, configuration: config)

        let styleCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        styleCollectionView.backgroundColor = .white
        styleCollectionView.alwaysBounceVertical = false

        return styleCollectionView
    }()

    private var colorKindSegmentControl: SimpleSegmentControl = .init()

    // MARK: - Properties

    private var styleDataSource: UICollectionViewDiffableDataSource<SectionKind, ColorItem>?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        configureStyleDataSource()
    }

    private func setupViews() {
        colorKindSegmentControl.addTarget(self, action: #selector(segmentActionHandler), for: .valueChanged)

        view.backgroundColor = .white

        colorKindSegmentControl.addSegment(title: "Color".localized)
        colorKindSegmentControl.addSegment(title: "Background".localized)

        view.addSubview(colorKindSegmentControl)
        view.addSubview(styleCollectionView)

        setupLayout()
    }

    private func setupLayout() {
        styleCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorKindSegmentControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            colorKindSegmentControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            colorKindSegmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorKindSegmentControl.heightAnchor.constraint(equalToConstant: 28),
            
            styleCollectionView.topAnchor.constraint(equalTo: colorKindSegmentControl.bottomAnchor, constant: 12),
            styleCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            styleCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            styleCollectionView.heightAnchor.constraint(equalToConstant: 104).usingPriority(.defaultHigh - 1),
            styleCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
    }

    private func configureStyleDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<StyleColorCellView, ColorItem> { (cell, indexPath, item) in
            var content = StyleColorCellContentConfiguration()
            content.color = item.color
            cell.contentConfiguration = content
        }

        styleDataSource = UICollectionViewDiffableDataSource<SectionKind, ColorItem>(collectionView: styleCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: ColorItem) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // initial data
        updateSnapshot(with: ColorItem.all)
    }

    @objc private func segmentActionHandler() {
        switch colorKindSegmentControl.selectedItemIndex {
        case 0:
            updateSnapshot(with: ColorItem.all)
        case 1:
            updateSnapshot(with: ColorItem.backgroundItems)
        default:
            assertionFailure("Add more cases to handle segment control index")
        }
    }

    private func updateSnapshot(with colorItems: [ColorItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, ColorItem>()

        let itemsInLastSection = colorItems.count % SectionKind.main.columnCount

        snapshot.appendSections([.main])
        snapshot.appendItems(colorItems.dropLast(itemsInLastSection))

        if itemsInLastSection != 0 {
            snapshot.appendSections([.last])
            snapshot.appendItems(colorItems.suffix(itemsInLastSection))
        }

        styleDataSource?.apply(snapshot, animatingDifferences: false)
    }
}
