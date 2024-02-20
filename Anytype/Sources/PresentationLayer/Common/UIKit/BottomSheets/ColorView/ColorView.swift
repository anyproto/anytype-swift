//
//  ColorViewSelection.swift
//  Anytype
//
//  Created by Denis Batvinkin on 09.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import UIKit

private enum SectionKind: Int, CaseIterable {
    case textColor
    case backgroundColor
}

extension ColorView {
    enum ColorItem: Hashable {
        case text(BlockColor)
        case background(BlockBackgroundColor)

        var color: UIColor {
            switch self {
            case .background(let color):
                return color.color
            case .text(let color):
                return color.color
            }
        }

        static let text = BlockColor.allCases.map { ColorItem.text($0) }
        static let background = BlockBackgroundColor.allCases.map { ColorItem.background($0) }
    }
}

class ColorView: UIView {
    // MARK: - Viwes

    private lazy var styleCollectionView: UICollectionView = {
        var config = UICollectionViewCompositionalLayoutConfiguration()

        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            let items = SectionKind(rawValue: sectionIndex) == .textColor ? ColorItem.text : ColorItem.background

            var groups: [NSCollectionLayoutItem] = []
            let itemDimension: CGSize = .init(width: 36.0, height: 34.0)

            // max count items in row
            let maxItemsInRow = Int(layoutEnvironment.container.contentSize.width / itemDimension.width)

            // calc last row items count
            let lastRowItemsCount = items.count % maxItemsInRow

            // add group for all items except last if lastRowItemsCount != 0
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemDimension.width), heightDimension: .absolute(itemDimension.height))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(itemDimension.height))
            let itemsGroup = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            // remain space in row after placing possible max count items
            let remainSpaceInRow: CGFloat = layoutEnvironment.container.contentSize.width - (CGFloat(maxItemsInRow) * itemDimension.width)
            // space for leading and trailing edge
            let edgeSpacing: CGFloat = remainSpaceInRow / 2
            itemsGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: edgeSpacing, bottom: 0, trailing: edgeSpacing)

            groups.append(itemsGroup)

            // add group for last row where items need to be centered
            if lastRowItemsCount != 0 {
                let lastRowGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(itemDimension.height))
                let lastRowItemsGroup = NSCollectionLayoutGroup.horizontal(layoutSize: lastRowGroupSize, subitems: [item])
                // left space in row
                let leftSpaceInRow: CGFloat = layoutEnvironment.container.contentSize.width - (CGFloat(lastRowItemsCount) * itemDimension.width)
                // space for leading and trailing edge
                let lastRowEdgeSpacing: CGFloat = leftSpaceInRow / 2
                lastRowItemsGroup.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: lastRowEdgeSpacing, bottom: 0, trailing: lastRowEdgeSpacing)

                groups.append(lastRowItemsGroup)
            }

            // main group - include itemsGroup and lastRowItemsGroup
            let mainGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
            let mainGroup = NSCollectionLayoutGroup.vertical(layoutSize: mainGroupSize, subitems: groups)

            let section = NSCollectionLayoutSection(group: mainGroup)

            if SectionKind(rawValue: sectionIndex) == .textColor {
                section.contentInsets = .init(top: 0, leading: 0, bottom: 7, trailing: 0)
            }

            return section

        }, configuration: config)

        let styleCollectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        styleCollectionView.backgroundColor = .clear
        styleCollectionView.isScrollEnabled = false
        styleCollectionView.delegate = self
        styleCollectionView.allowsMultipleSelection = true

        return styleCollectionView
    }()

    private let backdropView = UIView()
    let containerView = UIView()

    // MARK: - Properties

    private var styleDataSource: UICollectionViewDiffableDataSource<SectionKind, ColorItem>?
    var selectedTextColor: UIColor? {
        didSet {
            updateSnapshot()
        }
    }
    var selectedBackgroundColor: UIColor? {
        didSet {
            updateSnapshot()
        }
    }
    private var viewDidCloseHandler: () -> Void
    private var colorViewSelectedAction: (ColorItem) -> Void

    // MARK: - Lifecycle

    /// Init style view controller
    /// - Parameter color: Foreground color
    /// - Parameter backgroundColor: Background color
    init(
        colorViewSelectedAction: @escaping (ColorItem) -> Void,
        viewDidClose: @escaping () -> Void
    ) {
        self.colorViewSelectedAction = colorViewSelectedAction
        self.viewDidCloseHandler = viewDidClose

        super.init(frame: .zero)

        setupViews()
        configureStyleDataSource()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12.0
        containerView.layer.cornerCurve = .continuous

        containerView.layer.shadowColor = UIColor.Shadow.primary.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        containerView.layer.shadowRadius = 40
        containerView.layer.shadowOpacity = 1.0

        backgroundColor = .clear
        backdropView.backgroundColor = .clear
        let tapGeastureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backdropViewTapped))
        backdropView.addGestureRecognizer(tapGeastureRecognizer)

        addSubview(backdropView)
        addSubview(containerView)
        containerView.addSubview(styleCollectionView)
        containerView.backgroundColor = .Background.secondary

        setupLayout()
    }

    private func setupLayout() {
        backdropView.pinAllEdges(to: self)

        styleCollectionView.layoutUsing.anchors {
            $0.top.equal(to: containerView.topAnchor, constant: 15)
            $0.leading.equal(to: containerView.leadingAnchor, constant: 9)
            $0.trailing.equal(to: containerView.trailingAnchor, constant: -9)
            $0.bottom.equal(to: containerView.bottomAnchor)
        }
    }

    private func configureStyleDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<StyleColorCellView, ColorItem> { (cell, indexPath, item) in
            let content = StyleColorCellContentConfiguration(colorItem: item)
            cell.contentConfiguration = content
        }

        styleDataSource = UICollectionViewDiffableDataSource<SectionKind, ColorItem>(collectionView: styleCollectionView) {
            [weak self] (collectionView: UICollectionView, indexPath: IndexPath, identifier: ColorItem) -> UICollectionViewCell? in

            let color = SectionKind(rawValue: indexPath.section) == .textColor ? self?.selectedTextColor : self?.selectedBackgroundColor

            if identifier.color == color {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // initial data
        updateSnapshot()
    }

    private func updateSnapshot(with colorItems: [ColorItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, ColorItem>()
        snapshot.appendSections([.textColor, .backgroundColor])
        styleDataSource?.apply(snapshot, animatingDifferences: false)
    }

    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionKind, ColorItem>()
        snapshot.appendSections([.textColor, .backgroundColor])
        snapshot.appendItems(ColorItem.text, toSection: .textColor)
        snapshot.appendItems(ColorItem.background, toSection: .backgroundColor)
        styleDataSource?.apply(snapshot, animatingDifferences: false)
    }

    @objc private func backdropViewTapped() {
        viewDidCloseHandler()
    }
}

// MARK: - UICollectionViewDelegate

extension ColorView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        UISelectionFeedbackGenerator().selectionChanged()

        guard !(collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false) else { return false }
        guard let colorItem = styleDataSource?.itemIdentifier(for: indexPath) else {
            return false
        }
        let indexPathToDeselect = collectionView.indexPathsForSelectedItems?.filter { $0.section == indexPath.section }
        indexPathToDeselect?.forEach { collectionView.deselectItem(at: $0, animated: false) }

        switch colorItem {
        case .text(let color):
            self.selectedTextColor = color.color
        case .background(let color):
            self.selectedBackgroundColor = color.color
        }
        colorViewSelectedAction(colorItem)

        return true
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        guard !(collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false) else { return false }

        return true
    }
}
