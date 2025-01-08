import UIKit

final class SlashMenuViewController: UIViewController {
    let configurationFactory = SlashMenuContentConfigurationFactory()
    let viewModel: SlashMenuViewModel
    let dismissHandler: (() -> Void)?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(topBarTitle.isNil, animated: true)
        navigationController?.navigationBar.backItem?.title = ""
    }
    
    private func setup() {
        self.title = topBarTitle
        view.backgroundColor = .Background.primary
        
        view.addSubview(tableView) {
            $0.pinToSuperview()
        }
        
    }
    
    // MARK: - Views
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.titleSubtitleReuseCellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.relationReuseCellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.headerReuseCellId)
        
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
        label.textColor = .Text.secondary
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = Loc.noItemsMatchFilter
        return label
    }()
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SlashMenuViewController {
    
    enum Constants {
        static let titleSubtitleReuseCellId = "TitleSubtitleReuseCellId"
        static let relationReuseCellId = "RelationReuseCellId"
        static let headerReuseCellId = "HeaderReuseCellId"
    }
}
