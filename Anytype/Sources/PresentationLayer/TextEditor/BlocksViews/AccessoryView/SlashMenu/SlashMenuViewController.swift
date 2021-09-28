import UIKit

final class SlashMenuViewController: UIViewController {
    let configurationFactory = SlashMenuContentConfigurationFactory()
    let viewModel: SlashMenuViewModel
    let dismissHandler: (() -> Void)?
    
    let cellReuseId = NSStringFromClass(UITableViewCell.self)
    
    var cellData: [SlashMenuCellData] = [] {
        didSet {
            tableView.reloadData()
            tableView.backgroundView?.isHidden = !cellData.isEmpty
        }
    }
    
    private let topBarTitle: String?
    
    init(
        cellData: [SlashMenuCellData],
        topBarTitle: String?,
        actionsHandler: SlashMenuViewModel,
        dismissHandler: (() -> Void)?
    ) {
        self.cellData = cellData
        self.topBarTitle = topBarTitle
        self.viewModel = actionsHandler
        self.dismissHandler = dismissHandler
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    private func setup() {
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
            $0.height.equal(to: topBarTitle.isNotNil ? Constants.topBarHeight : 0)
        }
        view.addSubview(tableView) {
            $0.top.equal(to: customTopBar.bottomAnchor)
            $0.pinToSuperview(excluding: [.top])
        }
        
        view.backgroundColor = .backgroundPrimary
        titleLabel.text = topBarTitle
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
        label.textColor = .textPrimary
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
