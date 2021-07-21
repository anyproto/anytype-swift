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

        static let all: [Item] = [
            Item(kind: .header, text: "Title".localized, font: .heading),
            Item(kind: .header2, text: "Heading".localized, font: .subheading),
            Item(kind: .header3, text: "Subheading".localized, font: .headlineSemibold),
            Item(kind: .text, text: "Text".localized, font: UIFont.body)
        ]
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
    private var askTextAttributes: () -> TextAttributesViewController.AttributesState
    private var style: BlockText.Style
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
        askColor: @escaping () -> UIColor?,
        askBackgroundColor: @escaping () -> UIColor?,
        askTextAttributes: @escaping () -> TextAttributesViewController.AttributesState,
        actionHandler: @escaping ActionHandler
    ) {
        self.viewControllerForPresenting = viewControllerForPresenting
        self.style = style
        self.askColor = askColor
        self.askBackgroundColor = askBackgroundColor
        self.askTextAttributes = askTextAttributes
        self.actionHandler = actionHandler

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
            listStackView.addArrangedSubview(button)

            setupAction(for: button, with: item.kind)
        }
    }

    private func setupOtherStyleStackView() {
        let highlightedButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/highlighted"))
        setupAction(for: highlightedButton, with: .quote)
        let calloutButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/callout"))
        setupAction(for: calloutButton, with: .code)

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

    private func selectStyle(_ style: BlockText.Style, deselectAction: @escaping () -> Void) {
        guard style != self.style else { return }
        self.style = style

        currentDeselectAction?()
        currentDeselectAction = deselectAction
        self.actionHandler(BlockHandlerActionType.turnInto(style))
    }

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

        let color = askColor()
        let backgroundColor = askBackgroundColor()

        let contentVC = StyleColorViewController(color: color, backgroundColor: backgroundColor, actionHandler: actionHandler)
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

        let attributes = askTextAttributes()

        let contentVC = TextAttributesViewController(
            attributesState: attributes,
            actionHandler: actionHandler
        )
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
        selectStyle(style.kind) {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}
