import UIKit
import FloatingPanel
import BlocksModels
import Amplitude


// MARK: - Cell model

private extension StyleViewController {
    enum Section: Hashable {
        case main
    }

    struct Item: Hashable {
        let kind: BlockText.Style
        let text: String
        let font: UIFont

        private let identifier = UUID()

        static func all(selectedStyle: BlockText.Style) -> [Item] {
            let title: BlockText.Style = selectedStyle == .title ? .title : .header

            return [
                Item(kind: title, text: "Title".localized, font: .title),
                Item(kind: .header2, text: "Heading".localized, font: .heading),
                Item(kind: .header3, text: "Subheading".localized, font: .subheading),
                Item(kind: .text, text: "Text".localized, font: UIFont.bodyRegular)
            ]
        }
    }

    struct ListItem {
        let kind: BlockText.Style
        let icon: UIImage

        static let all: [ListItem] = [
            (BlockText.Style.bulleted, "StyleBottomSheet/bullet"),
            (BlockText.Style.checkbox, "StyleBottomSheet/checkbox"),
            (BlockText.Style.numbered, "StyleBottomSheet/numbered"),
            (BlockText.Style.toggle, "StyleBottomSheet/toggle")
        ]
        .compactMap { (kind, imageName) -> ListItem? in
            guard let image = UIImage(named: imageName) else { return nil }
            return ListItem(kind: kind, icon: image)
        }
    }
}

// MARK: - StyleViewController

final class StyleViewController: UIViewController {
    typealias ActionHandler = (_ action: BlockHandlerActionType) -> Void

    // MARK: - Views

    private lazy var styleCollectionView: UICollectionView = {
        var config = UICollectionViewCompositionalLayoutConfiguration()

        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(50), heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous

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
    private var askColor: () -> UIColor?
    private var askBackgroundColor: () -> UIColor?
    private var didTapMarkupButton: () -> Void
    private var style: BlockText.Style
    private var restrictions: BlockRestrictions
    // deselect action will be performed on new selection
    private var currentDeselectAction: (() -> Void)?

    // MARK: - Lifecycle

    /// Init style view controller
    /// - Parameter viewControllerForPresenting: view controller where we can present other view controllers
    /// - Parameter actionHandler: Handle bottom sheet  actions, see `StyleViewController.ActionType`
    /// - important: Use weak self inside `ActionHandler`
    init(
        viewControllerForPresenting: UIViewController,
        style: BlockText.Style,
        restrictions: BlockRestrictions,
        askColor: @escaping () -> UIColor?,
        askBackgroundColor: @escaping () -> UIColor?,
        didTapMarkupButton: @escaping () -> Void,
        actionHandler: @escaping ActionHandler
    ) {
        self.viewControllerForPresenting = viewControllerForPresenting
        self.style = style
        self.askColor = askColor
        self.askBackgroundColor = askBackgroundColor
        self.didTapMarkupButton = didTapMarkupButton
        self.actionHandler = actionHandler
        self.restrictions = restrictions

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Analytics
        Amplitude.instance().logEvent(AmplitudeEventsName.popupStyleMenu)

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

            if item.kind != self.style {
                let isEnabled = restrictions.turnIntoStyles.contains(.text(item.kind))
                button.isEnabled = isEnabled
            }
            listStackView.addArrangedSubview(button)

            setupAction(for: button, with: item.kind)

        }
    }

    private func setupOtherStyleStackView() {
        let highlightedButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/highlighted"))
        setupAction(for: highlightedButton, with: .quote)
        let calloutButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/callout"))
        setupAction(for: calloutButton, with: .code)

        if .quote != self.style {
            highlightedButton.isEnabled = restrictions.turnIntoStyles.contains(.text(.quote))
        }
        if .code != self.style {
            // TODO: add restrictions when callout block will be introduced
            calloutButton.isEnabled = false
        }

        let colorButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/color"))
        colorButton.layer.borderWidth = 0
        colorButton.addTarget(self, action: #selector(colorActionHandler), for: .touchUpInside)

        let moreButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/more"))
        moreButton.layer.borderWidth = 0
        moreButton.addAction(UIAction(handler: { [weak self] _ in
            self?.didTapMarkupButton()
        }), for: .touchUpInside)

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

    private func setupAction(for button: UIControl, with style: BlockText.Style) {
        let deselectAction = {
            button.isSelected = false
        }

        if style == self.style {
            button.isSelected = true
            currentDeselectAction = deselectAction
        }

        let action =  UIAction(
            handler: { [weak self] _ in
                button.isSelected = true

                self?.selectStyle(style) {
                    button.isSelected = false
                }
            }
        )

        button.addAction(action, for: .touchUpInside)
    }

    // MARK: - configure style collection view

    private func configureStyleDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<StyleCellView, Item> { [weak self] (cell, indexPath, item) in
            cell.isSelected = false

            if item.kind == self?.style {
                cell.isSelected = true
                self?.currentDeselectAction = {
                    cell.isSelected = false
                    self?.styleCollectionView.deselectItem(at: indexPath, animated: true)
                }
            }

            var content = StyleCellContentConfiguration()
            content.text = item.text
            content.font = item.font

            if item.kind != self?.style {
                let isDisabled = !(self?.restrictions.turnIntoStyles.contains(.text(item.kind)) ?? false)
                cell.isUserInteractionEnabled = !isDisabled
                content.isDisabled = isDisabled
            }

            cell.contentConfiguration = content
        }

        styleDataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: styleCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Item.all(selectedStyle: style))
        styleDataSource?.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - action handlers

    private func selectStyle(_ style: BlockText.Style, deselectAction: @escaping () -> Void) {
        guard style != self.style else { return }
        self.style = style

        currentDeselectAction?()
        currentDeselectAction = deselectAction
        if style == .code {
            actionHandler(.toggleWholeBlockMarkup(.keyboard))
        } else {
            actionHandler(.turnInto(style))
        }
    }

    @objc private func colorActionHandler() {
        guard let viewControllerForPresenting = viewControllerForPresenting else { return }

        let color = askColor()
        let backgroundColor = askBackgroundColor()

        let contentVC = StyleColorViewController(color: color, backgroundColor: backgroundColor, actionHandler: actionHandler)
        viewControllerForPresenting.embedChild(contentVC)

        contentVC.view.pinAllEdges(to: viewControllerForPresenting.view)
        contentVC.containerView.layoutUsing.anchors {
            $0.width.equal(to: 260)
            $0.height.equal(to: 176)
            $0.trailing.equal(to: view.trailingAnchor, constant: -10)
            $0.top.equal(to: view.topAnchor, constant: -8)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension StyleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let style = styleDataSource?.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }
        selectStyle(style.kind) {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}

// MARK: - FloatingPanelControllerDelegate

extension StyleViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_ fpc: FloatingPanelController, shouldRemoveAt location: CGPoint, with velocity: CGVector) -> Bool {
        let surfaceOffset = fpc.surfaceLocation.y - fpc.surfaceLocation(for: .full).y
        // If panel moved more than a half of its hight than hide panel
        if fpc.surfaceView.bounds.height / 2 < surfaceOffset {
            return true
        }
        return false
    }
}
