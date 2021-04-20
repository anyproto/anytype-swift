
import UIKit

final class BlockMenuItemsViewController: BaseBlockMenuItemsViewController {
    
    private enum Constants {
        static let cellReuseId = UITableViewCell.cellReuseIdentifier()
        static let cellHeight: CGFloat = 55
        static let dividerCellhHeight: CGFloat = 35
        static let separatorInsets = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 16)
        static let imageToTextPadding: CGFloat = 30
    }
    
    private let coordinator: BlockMenuItemsViewControllerCoordinator
    private let items: [BlockActionMenuItem]
    
    init(coordinator: BlockMenuItemsViewControllerCoordinator, items: [BlockActionMenuItem]) {
        self.coordinator = coordinator
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTableView()
    }
    
    private func addTableView() {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = Constants.separatorInsets
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseId)
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
        if let subtitle = displayData.subtitle {
            configuration.secondaryText = subtitle
            configuration.secondaryTextProperties.font = .captionFont
            configuration.secondaryTextProperties.color = .secondaryTextColor
        }
        return configuration
    }
}

extension BlockMenuItemsViewController: UITableViewDelegate {
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
        var configuration = cell.defaultContentConfiguration()
        cell.accessoryType = .none
        configuration.imageToTextPadding = Constants.imageToTextPadding
        let item = self.items[indexPath.row]
        switch item {
        case let .action(action):
            configuration = self.setup(configuration: configuration, displayData: action.displayData)
        case let .menu(type, children):
            configuration = self.setup(configuration: configuration, displayData: type.displayData)
            cell.accessoryType = children.isEmpty ? .none : .disclosureIndicator
        case let .sectionDivider(title):
            configuration.textProperties.font = .captionFont
            configuration.text = title
        }
        cell.contentConfiguration = configuration
        return cell
    }
}
