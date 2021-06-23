import UIKit

final class SlashMenuItemsViewController: BaseAccessoryMenuItemsViewController {
    
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
    
    private let coordinator: SlashMenuItemsViewControllerCoordinator
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseId)
        return tableView
    }()
    private let filterService: SlashMenuActionsFilterService
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
    
    init(coordinator: SlashMenuItemsViewControllerCoordinator, items: [BlockActionMenuItem]) {
        self.coordinator = coordinator
        self.items = items
        self.filterService = SlashMenuActionsFilterService(initialMenuItems: items)
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
    
    private func configuration(for item: BlockActionMenuItem) -> UIContentConfiguration {
        switch item {
        case let .menu(itemType, _):
            return makeConfiguration(displayData: itemType.displayData)
        case let .action(action):
            return makeConfiguration(displayData: action.displayData)
        case let .sectionDivider(divider):
            return makeConfigurationForDivider(title: divider)
        }
    }
    
    private func makeConfigurationForDivider(title: String) -> UIContentConfiguration {
        var configuration = UIListContentConfiguration.subtitleCell()
        configuration.textProperties.font = .captionFont
        configuration.text = title
        return configuration
    }
    
    private func makeConfiguration(displayData: SlashMenuItemDisplayData) -> UIContentConfiguration {
        switch displayData.iconData {
        case let .imageNamed(imageName):
            return makeConfiguration(with: displayData.title,
                                     subtitle: displayData.subtitle,
                                     imageName: imageName)
        case let .emoji(emoji):
            return ContentConfigurationWithEmoji(emoji: emoji,
                                                 name: displayData.title,
                                                 description: displayData.subtitle)
        }
    }
    
    private func makeConfiguration(with title: String,
                                   subtitle: String?,
                                   imageName: String) -> UIContentConfiguration {
        var configuration = UIListContentConfiguration.subtitleCell()
        configuration.text = title
        configuration.textProperties.font = .bodyFont
        configuration.textProperties.color = .textColor
        configuration.image = UIImage(named: imageName)
        configuration.imageToTextPadding = Constants.imageToTextPadding
        configuration.imageProperties.reservedLayoutSize = Constants.imageSize
        configuration.imageProperties.maximumSize = Constants.imageSize
        if let subtitle = subtitle {
            configuration.secondaryText = subtitle
            configuration.secondaryTextProperties.font = .smallBodyFont
            configuration.secondaryTextProperties.color = .secondaryTextColor
        }
        return configuration
    }
}

extension SlashMenuItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch items[indexPath.row] {
        case .sectionDivider:
            return false
        case .action, .menu:
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator.didSelect(items[indexPath.row], in: self)
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

extension SlashMenuItemsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath)
        cell.accessoryType = .none
        let item = self.items[indexPath.row]
        switch item {
        case .action:
            cell.separatorInset = Constants.separatorInsets
        case let .menu(_, children):
            cell.accessoryType = children.isEmpty ? .none : .disclosureIndicator
            cell.separatorInset = Constants.separatorInsets
        case .sectionDivider:
            cell.separatorInset = Constants.dividerSeparatorInsets
        }
        cell.contentConfiguration = configuration(for: item)
        return cell
    }
}
