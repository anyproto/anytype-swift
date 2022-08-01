import UIKit

protocol MentionsView: AnyObject {
    func display(_ list: [MentionDisplayData])
    func update( mention: MentionDisplayData)
    func dismiss()
}

final class MentionsViewController: UITableViewController {
    let viewModel: MentionsViewModel
    private lazy var dataSource = makeDataSource()
    private let dismissAction: (() -> Void)?
    
    init(
        viewModel: MentionsViewModel,
        dismissAction: (() -> Void)?
    ) {
        self.viewModel = viewModel
        self.dismissAction = dismissAction
        super.init(style: .plain)
        
        setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.obtainMentions()
    }
    
    private func setup() {
        tableView.separatorInset = Constants.separatorInsets
        tableView.rowHeight = Constants.cellHeight
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseId)
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .createNewObject:
            viewModel.didSelectCreateNewMention()
        case let .mention(mention):
            viewModel.didSelectMention(mention, index: indexPath.row)
        }
    }
    
    private func makeDataSource() -> UITableViewDiffableDataSource<MentionSection, MentionDisplayData> {
        UITableViewDiffableDataSource<MentionSection, MentionDisplayData>(tableView: tableView) { [weak self] tableView, indexPath, displayData -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath)
            switch displayData {
            case .createNewObject:
                cell.contentConfiguration = self?.createNewObjectContentConfiguration()
            case let .mention(mention):
                cell.contentConfiguration = self?.confguration(for: mention)
            }
            return cell
        }
    }
    
    private func confguration(for mention: MentionObject) -> UIContentConfiguration {
        EditorSearchCellConfiguration(
            cellData: EditorSearchCellData(
                title: mention.name,
                subtitle: mention.type?.name ?? Loc.object,
                icon: mention.objectIcon,
                expandedIcon: false
            )
        )
    }
    
    private func createNewObjectContentConfiguration() -> UIContentConfiguration {
        var configuration = UIListContentConfiguration.cell()
        configuration.text = Loc.createNewObject
        configuration.textProperties.font = .uxTitle2Regular
        configuration.textProperties.color = .textSecondary
        
        configuration.image = UIImage(named: "createNewObject")
        configuration.imageProperties.reservedLayoutSize = CGSize(width: 40, height: 40)
        configuration.imageProperties.maximumSize = CGSize(width: 40, height: 40)
        configuration.imageToTextPadding = Constants.createNewObjectImagePadding
        return configuration
    }
    
    // MARK: - Constants
    private enum Constants {
        static let cellReuseId = NSStringFromClass(UITableViewCell.self)
        static let separatorInsets = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 20)
        static let cellHeight: CGFloat = 56
        static let createNewObjectImagePadding: CGFloat = 12
    }
    
    // MARK: - Unavailable
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MentionsViewController: MentionsView {
    
    func display(_ list: [MentionDisplayData]) {
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<MentionSection, MentionDisplayData>()
            snapshot.appendSections(MentionSection.allCases)
            snapshot.appendItems([.createNewObject], toSection: .first)
            snapshot.appendItems(list, toSection: .second)
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    func update(mention: MentionDisplayData) {
        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.reloadItems([mention])
            self.dataSource.apply(snapshot)
        }
    }
    
    func dismiss() {
        dismissAction?()
    }
}
