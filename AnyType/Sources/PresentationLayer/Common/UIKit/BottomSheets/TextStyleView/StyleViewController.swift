//
//  StyleViewController.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.04.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import UIKit
import FloatingPanel


// MARK: - Cell model

private extension StyleViewController {
    enum Section: Hashable {
        case main
    }

    struct Item: Hashable {
        let kind: BlockActionHandler.ActionType
        let text: String
        let font: UIFont

        private let identifier = UUID()

        static let all: [Item] = [
            (BlockActionHandler.ActionType.turnInto(.title), "Title".localized, UIFont.header1Font),
            (BlockActionHandler.ActionType.turnInto(.header2), "Heading".localized, UIFont.header2Font),
            (BlockActionHandler.ActionType.turnInto(.header3), "Subheading".localized, UIFont.header3Font),
            (BlockActionHandler.ActionType.turnInto(.text), "Text".localized, UIFont.bodyFont)
        ].map { Item(kind: $0.0, text: $0.1, font: $0.2) }
    }

    struct ListItem {
        let icon: UIImage

        static let all: [ListItem] = [
            "StyleBottomSheet/bullet",
            "StyleBottomSheet/checkbox",
            "StyleBottomSheet/numbered",
            "StyleBottomSheet/toggle"
        ].compactMap { UIImage(named: $0) }.map(ListItem.init)
    }
}

// MARK: - StyleViewController

final class StyleViewController: UIViewController {
    typealias ActionHandler = (_ action: BlockActionHandler.ActionType) -> Void

    // MARK: - Views

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
        styleCollectionView.alwaysBounceHorizontal = true
        styleCollectionView.delegate = self

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

    // MARK: - Other properties

    private weak var viewControllerForPresenting: UIViewController?
    private var actionHandler: ActionHandler

    // MARK: - Lifecycle

    /// Init style view controller
    /// - Parameter viewControllerForPresenting: view controller where we can present other view controllers
    /// - Parameter actionHandler: Handle bottom sheet  actions, see `StyleViewController.ActionType`
    /// - important: Use weak self inside `ActionHandler`
    init(viewControllerForPresenting: UIViewController, actionHandler: @escaping ActionHandler) {
        self.viewControllerForPresenting = viewControllerForPresenting
        self.actionHandler = actionHandler
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        configureStyleDataSource()
    }

    // MARK: - Setup views

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
        colorButton.addTarget(self, action: #selector(colorActionHandler), for: .touchUpInside)

        let moreButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/more"))
        moreButton.layer.borderWidth = 0
        moreButton.addTarget(self, action: #selector(moreActionHandler), for: .touchUpInside)

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

    // MARK: - configure style collection view

    private func configureStyleDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<StyleCellView, Item> { (cell, indexPath, item) in
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

    // MARK: - action handlers

    @objc private func colorActionHandler() {
        guard let viewControllerForPresenting = viewControllerForPresenting else { return }

        let fpc = FloatingPanelController()
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 16.0
        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.grayscale90
        shadow.offset = CGSize(width: 0, height: 4)
        shadow.radius = 40
        shadow.opacity = 0.25
        appearance.shadows = [shadow]

        let sizeDifference = StylePanelLayout.Constant.panelHeight -  StyleColorPanelLayout.Constant.panelHeight
        fpc.layout = StyleColorPanelLayout(additonalHeight: sizeDifference)

        let bottomInset = viewControllerForPresenting.view.safeAreaInsets.bottom + 6 + sizeDifference
        fpc.surfaceView.containerMargins = .init(top: 0, left: 10.0, bottom: bottomInset, right: 10.0)
        fpc.surfaceView.layer.cornerCurve = .continuous
        fpc.surfaceView.grabberHandleSize = .init(width: 48.0, height: 4.0)
        fpc.surfaceView.grabberHandle.barColor = .grayscale30
        fpc.surfaceView.appearance = appearance
        fpc.isRemovalInteractionEnabled = true
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        fpc.backdropView.backgroundColor = .clear
        fpc.contentMode = .static

        let contentVC = StyleColorViewController()
        fpc.set(contentViewController: contentVC)
        fpc.addPanel(toParent: viewControllerForPresenting, animated: true)
    }

    @objc private func moreActionHandler() {
        guard let viewControllerForPresenting = viewControllerForPresenting else { return }

        let fpc = FloatingPanelController()
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 16.0
        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.grayscale90
        shadow.offset = CGSize(width: 0, height: 4)
        shadow.radius = 40
        shadow.opacity = 0.25
        appearance.shadows = [shadow]

        let sizeDifference = StylePanelLayout.Constant.panelHeight -  TextAttributesPanelLayout.Constant.panelHeight
        fpc.layout = TextAttributesPanelLayout(additonalHeight: sizeDifference)

        let bottomInset = viewControllerForPresenting.view.safeAreaInsets.bottom + 6 + sizeDifference
        fpc.surfaceView.containerMargins = .init(top: 0, left: 10.0, bottom: bottomInset, right: 10.0)
        fpc.surfaceView.layer.cornerCurve = .continuous
        fpc.surfaceView.grabberHandleSize = .init(width: 48.0, height: 4.0)
        fpc.surfaceView.grabberHandle.barColor = .grayscale30
        fpc.surfaceView.appearance = appearance
        fpc.isRemovalInteractionEnabled = true
        fpc.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        fpc.backdropView.backgroundColor = .clear
        fpc.contentMode = .static

        let contentVC = TextAttributesViewController()
        fpc.set(contentViewController: contentVC)
        fpc.addPanel(toParent: viewControllerForPresenting, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension StyleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let style = styleDataSource?.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        self.actionHandler(style.kind)
    }
}
