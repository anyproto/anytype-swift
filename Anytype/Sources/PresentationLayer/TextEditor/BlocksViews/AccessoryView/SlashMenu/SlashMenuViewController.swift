import UIKit

enum SlashMenuCellData {
    case menu(item: SlashMenuItemType, actions: [SlashAction])
    case action(SlashAction)
    case header(title: String)
}

final class SlashMenuViewController: UIViewController {
    let configurationFactory = SlashMenuContentConfigurationFactory()
    let actionsHandler: SlashMenuViewModel
    let dismissHandler: (() -> Void)?
    
    let cellReuseId = NSStringFromClass(UITableViewCell.self)
    
    var cellData: [SlashMenuCellData] = [] {
        didSet {
            tableView.reloadData()
            tableView.backgroundView?.isHidden = !cellData.isEmpty
        }
    }
    
    private lazy var topBarHeightConstraint = customTopBar.heightAnchor.constraint(equalToConstant: Constants.topBarHeight)
    
    init(
        cellData: [SlashMenuCellData],
        actionsHandler: SlashMenuViewModel,
        dismissHandler: (() -> Void)?
    ) {
        self.cellData = cellData
        self.actionsHandler = actionsHandler
        self.dismissHandler = dismissHandler
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    private func setup() {
        view = UIView()
        view.backgroundColor = .systemBackground
        
        customTopBar.addSubview(backButton) {
            $0.trailing.equal(to: customTopBar.trailingAnchor, constant: -Constants.backButtonTrailingPadding)
            $0.centerY.equal(to: customTopBar.centerYAnchor)
        }
        customTopBar.addSubview(titleLabel) {
            $0.leading.equal(to: customTopBar.leadingAnchor, constant: Constants.labelLeadingPadding)
            $0.centerY.equal(to: customTopBar.centerYAnchor)
        }
        view.addSubview(customTopBar) {
            $0.pinToSuperview(excluding: [.bottom])
        }
        topBarHeightConstraint.isActive = true
        
        titleLabel.text = self.title
        view.addSubview(tableView) {
            $0.pinToSuperview(excluding: [.top])
            $0.top.equal(to: customTopBar.bottomAnchor)
        }
    }
    
    func setTopBarHidden(_ hidden: Bool) {
        topBarHeightConstraint.constant = hidden ? 0 : Constants.topBarHeight
    }
    
    // MARK: - Views
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseId)
        
        tableView.backgroundView = emptyView
        emptyView.isHidden = true
        
        return tableView
    }()
    
    private lazy var emptyView: UIView = {
        let emptyView = UIView()
        emptyView.addSubview(noItemsLabel) {
            $0.center(in: emptyView)
        }
        return emptyView
    }()
    
    private let noItemsLabel: UILabel = {
        let label = UILabel()
        label.font = .uxCalloutRegular
        label.textColor = .textSecondary
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = "No items match filter".localized
        return label
    }()
    
    private let customTopBar = UIView()
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.font = .caption1Medium
        return label
    }()
    
    private lazy var backButton = ButtonsFactory.makeBackButton { [weak self] _ in
        self?.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Constants
    
    private enum Constants {
        static let topBarHeight: CGFloat = 30
        static let backButtonTrailingPadding: CGFloat = 20
        static let labelLeadingPadding: CGFloat = 20
    }
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
