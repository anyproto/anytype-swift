
import UIKit

final class BlockMenuItemsViewController: BaseBlockMenuItemsViewController {
    
    private enum Constants {
        static let cellReuseId = NSStringFromClass(UITableViewCell.self)
        static let cellHeight: CGFloat = 55
        static let dividerCellhHeight: CGFloat = 35
        static let separatorInsets = UIEdgeInsets(top: 0, left: 68, bottom: 0, right: 16)
        static let dividerSeparatorInsets = UIEdgeInsets(top: 0,
                                                         left: UIScreen.main.bounds.width,
                                                         bottom: 0,
                                                         right: -UIScreen.main.bounds.width)
        static let imageSize = CGSize(width: 24, height: 24)
        static let imageToTextPadding: CGFloat = 22
    }
    
    private let coordinator: BlockMenuItemsViewControllerCoordinator
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseId)
        return tableView
    }()
    private let filterService: BlockMenuActionsFilterService
    private(set) var items: [BlockActionMenuItem] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var filterString = "" {
        didSet {
            updateFiltering()
        }
    }
    
    init(coordinator: BlockMenuItemsViewControllerCoordinator, items: [BlockActionMenuItem]) {
        self.coordinator = coordinator
        self.items = items
        self.filterService = BlockMenuActionsFilterService(initialMenuItems: items)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTableView()
    }
    
    private func updateFiltering() {
        if filterString.isEmpty {
            items = filterService.initialMenuItems
        } else {
            items = filterService.menuItemsFiltered(by: filterString)
        }
    }
    
    private func addTableView() {
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.customTopBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func setup(configuration: UIListContentConfiguration,
                       displayData: BlockMenuItemSimpleDisplayData) -> UIListContentConfiguration {
        var configuration = configuration
        configuration.text = displayData.title
        configuration.textProperties.font = .bodyFont
        configuration.textProperties.color = .textColor
        configuration.image = UIImage(named: displayData.imageName)
        configuration.imageToTextPadding = Constants.imageToTextPadding
        configuration.imageProperties.reservedLayoutSize = Constants.imageSize
        configuration.imageProperties.maximumSize = Constants.imageSize
        if let subtitle = displayData.subtitle {
            configuration.secondaryText = subtitle
            configuration.secondaryTextProperties.font = .smallBodyFont
            configuration.secondaryTextProperties.color = .secondaryTextColor
        }
        return configuration
    }
}

extension BlockMenuItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch items[indexPath.row] {
        case .sectionDivider:
            return false
        case .action, .menu:
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.coordinator.didSelect(self.items[indexPath.row], in: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.items[indexPath.row]
        switch item {
        case .action, .menu:
            return Constants.cellHeight
        case .sectionDivider:
            return Constants.dividerCellhHeight
        }
    }
}

extension BlockMenuItemsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath)
        var configuration = UIListContentConfiguration.subtitleCell()
        cell.accessoryType = .none
        let item = self.items[indexPath.row]
        switch item {
        case let .action(action):
            configuration = self.setup(configuration: configuration, displayData: action.displayData)
            cell.separatorInset = Constants.separatorInsets
        case let .menu(type, children):
            configuration = self.setup(configuration: configuration, displayData: type.displayData)
            cell.accessoryType = children.isEmpty ? .none : .disclosureIndicator
            cell.separatorInset = Constants.separatorInsets
        case let .sectionDivider(title):
            configuration.textProperties.font = .captionFont
            configuration.text = title
            cell.separatorInset = Constants.dividerSeparatorInsets
        }
        cell.contentConfiguration = configuration
        return cell
    }
}
