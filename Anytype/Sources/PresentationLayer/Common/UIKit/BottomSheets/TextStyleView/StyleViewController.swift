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
            (BlockText.Style.checkbox, "StyleBottomSheet/checkbox"),
            (BlockText.Style.bulleted, "StyleBottomSheet/bullet"),
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

    // MARK: - Views

    let layoutGuide = UILayoutGuide()

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
        styleCollectionView.backgroundColor = .backgroundSecondary
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
        listStackView.spacing = 7
        listStackView.translatesAutoresizingMaskIntoConstraints = false

        return listStackView
    }()

    private var otherStyleStackView: UIStackView = {
        let otherStyleStackView = UIStackView()
        otherStyleStackView.distribution = .fillEqually
        otherStyleStackView.axis = .horizontal
        otherStyleStackView.spacing = 7
        otherStyleStackView.translatesAutoresizingMaskIntoConstraints = false

        return otherStyleStackView
    }()

    private var containerStackView: UIStackView = {
        let containerStackView = UIStackView()
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.axis = .vertical
        containerStackView.spacing = 16

        return containerStackView
    }()

    // MARK: - Other properties

    private weak var viewControllerForPresenting: UIViewController?
    private let blockId: BlockId
    private let actionHandler: BlockActionHandlerProtocol
    private var askColor: () -> UIColor?
    private var askBackgroundColor: () -> UIColor?
    private var didTapMarkupButton: (_ styleView: UIView, _ viewDidClose: @escaping () -> Void) -> Void
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
        blockId: BlockId,
        viewControllerForPresenting: UIViewController,
        style: BlockText.Style,
        restrictions: BlockRestrictions,
        askColor: @escaping () -> UIColor?,
        askBackgroundColor: @escaping () -> UIColor?,
        didTapMarkupButton: @escaping (_ styleView: UIView, _ viewDidClose: @escaping () -> Void) -> Void,
        actionHandler: BlockActionHandlerProtocol
    ) {
        self.blockId = blockId
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

        setupViews()
        configureStyleDataSource()
    }

    // MARK: - Setup views

    private func setupViews() {
        view.backgroundColor = .backgroundSecondary

        containerStackView.addArrangedSubview(listStackView)
        containerStackView.addArrangedSubview(otherStyleStackView)

        otherStyleStackView.layoutUsing.anchors {
            $0.height.equal(to: 52)
        }
        listStackView.layoutUsing.anchors {
            $0.height.equal(to: 52)
        }

        view.addSubview(styleCollectionView)
        view.addSubview(containerStackView)

        setupListStackView()
        setupOtherStyleStackView()
        setupLayout()
        setupLayoutGuide()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            styleCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            styleCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            styleCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            styleCollectionView.heightAnchor.constraint(equalToConstant: 52),

            containerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerStackView.topAnchor.constraint(equalTo: styleCollectionView.bottomAnchor, constant: 16),

            view.heightAnchor.constraint(equalToConstant: 232)
        ])
        view.addLayoutGuide(layoutGuide)
    }

    private func setupLayoutGuide() {
        view.addLayoutGuide(layoutGuide)
    }

    private func setupListStackView() {
        ListItem.all.forEach { item in
            let button = ButtonsFactory.roundedBorderуButton(image: item.icon)

            if item.kind != self.style {
                let isEnabled = restrictions.turnIntoStyles.contains(.text(item.kind))
                button.isEnabled = isEnabled
            }
            listStackView.addArrangedSubview(button)
            setupAction(for: button, with: item.kind)
        }
    }

    private func setupOtherStyleStackView() {
        let smallButtonSize = CGSize(width: 32, height: 32)

        let highlightedButton = ButtonsFactory.roundedBorderуButton(image: UIImage.highlightImage())
        highlightedButton.setImageTintColor(.textSecondary, state: .disabled)
        setupAction(for: highlightedButton, with: .quote)

        let calloutImage = UIImage.imageWithText(
            "Callout".localized,
        textColor: .code != self.style ? .textTertiary : .textPrimary,
            backgroundColor: .backgroundSelected,
            font: .uxCalloutRegular,
            size: .init(width: 63, height: 28),
            cornerRadius: 6
        )

        #warning("add restrictions when callout block will be introduced")
        let calloutButton = ButtonsFactory.roundedBorderуButton(image: calloutImage)
        calloutButton.isEnabled = .code == self.style
        setupAction(for: calloutButton, with: .code)

        if .quote != self.style {
            highlightedButton.isEnabled = restrictions.turnIntoStyles.contains(.text(.quote))
        }

        let colorButton = ButtonsFactory.roundedBorderуButton(image: UIImage(named: "StyleBottomSheet/color"))
        colorButton.layer.borderWidth = 0
        colorButton.layer.cornerRadius = smallButtonSize.height / 2
        colorButton.setBackgroundColor(.backgroundSelected, state: .selected)
        colorButton.addTarget(self, action: #selector(colorActionHandler), for: .touchUpInside)

        let image = UIImage.more.withTintColor(.textSecondary)
        let moreButton = ButtonsFactory.roundedBorderуButton(image: image)
        moreButton.layer.borderWidth = 0
        moreButton.layer.cornerRadius = smallButtonSize.height / 2
        moreButton.setBackgroundColor(.backgroundSelected, state: .selected)
        
        moreButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self = self else { return }
            moreButton.isSelected = true

            // show markup view
            self.didTapMarkupButton(self.view) {
                // unselect button on closing markup view
                moreButton.isSelected = false
            }
            UISelectionFeedbackGenerator().selectionChanged()
        }), for: .touchUpInside)

        let containerForColorAndMoreView = UIView()

        // setup constraints
        containerForColorAndMoreView.layoutUsing.stack {
            $0.layoutUsing.anchors {
                $0.center(in: containerForColorAndMoreView)
            }
        } builder: {
            colorButton.layoutUsing.anchors {
                $0.size(smallButtonSize)
            }
            moreButton.layoutUsing.anchors {
                $0.size(smallButtonSize)
            }

            return $0.hStack(
                colorButton,
                $0.hGap(fixed: 10),
                moreButton
            )
        }

        otherStyleStackView.addArrangedSubview(highlightedButton)
        otherStyleStackView.addArrangedSubview(calloutButton)
        otherStyleStackView.addArrangedSubview(containerForColorAndMoreView)
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
                UISelectionFeedbackGenerator().selectionChanged()
            }
        )

        button.addAction(action, for: .touchUpInside)
    }

    // MARK: - configure style collection view

    private func configureStyleDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<StyleCellView, Item> { [weak self] (cell, indexPath, item) in

            if item.kind == self?.style, !cell.isSelected {
                cell.isSelected = true
                self?.styleCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .right)
                self?.currentDeselectAction = {  self?.styleCollectionView.deselectItem(at: indexPath, animated: true) }
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
            actionHandler.toggleWholeBlockMarkup(.keyboard, blockId: blockId)
        } else {
            actionHandler.turnInto(style, blockId: blockId)
        }
    }

    @objc private func colorActionHandler(button: UIControl) {
        guard let viewControllerForPresenting = viewControllerForPresenting else { return }

        button.isSelected = true

        let color = askColor() ?? .textPrimary
        let backgroundColor = askBackgroundColor() ?? .backgroundPrimary

        let contentVC = StyleColorViewController(
            blockId: blockId,
            color: color,
            backgroundColor: backgroundColor,
            actionHandler: actionHandler
        ) {
            button.isSelected = false
        }
        viewControllerForPresenting.embedChild(contentVC)

        contentVC.view.pinAllEdges(to: viewControllerForPresenting.view)
        contentVC.colorView.containerView.layoutUsing.anchors {
            $0.width.equal(to: 260)
            $0.height.equal(to: 176)
            $0.trailing.equal(to: view.trailingAnchor, constant: -10)
            $0.top.equal(to: view.topAnchor, constant: -8)
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// MARK: - UICollectionViewDelegate

extension StyleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UISelectionFeedbackGenerator().selectionChanged()
        guard let style = styleDataSource?.itemIdentifier(for: indexPath) else {
            collectionView.deselectItem(at: indexPath, animated: true)
            return
        }

        selectStyle(style.kind) { [weak self] in
            self?.styleCollectionView.deselectItem(at: indexPath, animated: true)
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

private extension UIImage {
    static func highlightImage() -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: 70, height: 24)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .right
        nameLabel.textColor = .buttonSelected
        nameLabel.font = AnytypeFont.uxCalloutRegular.uiKitFont
        nameLabel.text = "Highlight".localized

        let backgroundView = UIView(frame: .init(x: 9, y: 4, width: 0, height: 0))
        backgroundView.addSubview(nameLabel)

        let quoteView = UIView(frame: .init(x: 0, y: 0, width: 1, height: frame.height))
        quoteView.backgroundColor = .buttonSelected

        backgroundView.addSubview(quoteView)
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIApplication.shared.keyWindow?.screen.scale ?? 0)
        if let currentContext = UIGraphicsGetCurrentContext() {
            backgroundView.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameImage?.withRenderingMode(.alwaysTemplate)
        }

        return nil
    }
}
