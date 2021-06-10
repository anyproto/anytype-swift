
import UIKit

final class MentionsViewController: UITableViewController {
    
    private enum Constants {
        static let cellReuseId = NSStringFromClass(UITableViewCell.self)
        static let imageCornerrRadius: CGFloat = 8
        static let imageSize = CGSize(width: 40, height: 40)
        static let separatorInsets = UIEdgeInsets(top: 0, left: 68, bottom: 0, right: 24)
        static let imagePadding: CGFloat = 12
        static let cellHeight: CGFloat = 55
        static let textsVerticalPadding: CGFloat = 4
        static let createNewObjectImagePadding: CGFloat = 12
    }
    
    let viewModel: MentionsViewModel
    private lazy var dataSource = makeDataSource()
    
    init(style: UITableView.Style, viewModel: MentionsViewModel) {
        self.viewModel = viewModel
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInset = Constants.separatorInsets
        tableView.rowHeight = Constants.cellHeight
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseId)
        tableView.tableFooterView = UIView(frame: .zero)
        viewModel.setup(with: self)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        switch item {
        case .createNewObject:
            viewModel.createNewMention()
        case let .mention(mention):
            viewModel.didSelectMention(mention)
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
        switch mention.iconData {
        case .none:
            return MentionWithEmojiContentConfiguration(emoji: mention.name?.first?.uppercased() ?? "",
                                                        name: mention.name,
                                                        description: mention.description)
        case let .emoji(emoji):
            return MentionWithEmojiContentConfiguration(emoji: emoji.value,
                                                        name: mention.name,
                                                        description: mention.description)
        case .imageId:
            return mentionWithImageConfiguration(mention: mention)
        }
    }
    
    private func mentionWithImageConfiguration(mention: MentionObject) -> UIContentConfiguration {
        var configuration = UIListContentConfiguration.subtitleCell()
        
        configuration.imageProperties.cornerRadius = Constants.imageCornerrRadius
        configuration.imageProperties.maximumSize = Constants.imageSize
        configuration.imageProperties.reservedLayoutSize = Constants.imageSize
        configuration.imageToTextPadding = Constants.imagePadding
        configuration.image = viewModel.image(for: mention)
        
        configuration.text = mention.name
        configuration.textProperties.font = .bodyFont
        configuration.textProperties.color = .textColor
        configuration.textToSecondaryTextVerticalPadding = Constants.textsVerticalPadding
        
        configuration.secondaryText = mention.description
        configuration.secondaryTextProperties.font = .captionFont
        configuration.secondaryTextProperties.color = .secondaryTextColor
        return configuration
    }
    
    private func createNewObjectContentConfiguration() -> UIContentConfiguration {
        var configuration = UIListContentConfiguration.cell()
        configuration.text = "Create new object".localized
        configuration.textProperties.font = .bodyFont
        configuration.textProperties.color = .secondaryTextColor
        
        configuration.image = UIImage(named: "createNewObject")
        configuration.imageProperties.reservedLayoutSize = CGSize(width: 40, height: 40)
        configuration.imageProperties.maximumSize = CGSize(width: 40, height: 40)
        configuration.imageToTextPadding = Constants.createNewObjectImagePadding
        return configuration
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
}
