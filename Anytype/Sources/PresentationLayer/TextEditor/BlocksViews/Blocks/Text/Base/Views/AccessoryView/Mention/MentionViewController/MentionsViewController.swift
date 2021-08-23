
import UIKit

final class MentionsViewController: UITableViewController {
    
    private enum Constants {
        static let cellReuseId = NSStringFromClass(UITableViewCell.self)
        static let imageCornerRadius: CGFloat = 8
        static let imageSize = CGSize(width: 40, height: 40)
        static let separatorInsets = UIEdgeInsets(top: 0, left: 68, bottom: 0, right: 24)
        static let imagePadding: CGFloat = 12
        static let cellHeight: CGFloat = 55
        static let textsVerticalPadding: CGFloat = 4
        static let createNewObjectImagePadding: CGFloat = 12
    }
    
    let viewModel: MentionsViewModel
    private lazy var dataSource = makeDataSource()
    private let dismissAction: (() -> Void)?
    
    init(style: UITableView.Style,
         viewModel: MentionsViewModel,
         dismissAction: (() -> Void)?) {
        self.viewModel = viewModel
        self.dismissAction = dismissAction
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
            viewModel.didSelectCreateNewMention()
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
        switch mention.icon {
        case let .objectIcon(objectIcon):
            return configurationForObjectIcon(objectIcon, mention: mention)
        case .checkmark:
            return mentionWithImageConfiguration(mention: mention, isCircle: false)
        case .none:
            return ContentConfigurationWithEmoji(
                emoji: "",
                name: mention.name,
                description: mention.description
            )
        }
    }
    
    private func configurationForObjectIcon(_ objectIcon: DocumentIconType, mention: MentionObject) -> UIContentConfiguration {
        switch objectIcon {
        case let .profile(profile):
            switch profile {
            case .imageId:
                return mentionWithImageConfiguration(mention: mention, isCircle: true)
            case .placeholder:
                return mentionWithImageConfiguration(mention: mention, isCircle: true)
            }
        case let .basic(basic):
            switch basic {
            case let .emoji(emoji):
                return ContentConfigurationWithEmoji(
                    emoji: emoji.value,
                    name: mention.name,
                    description: mention.description
                )
            case .imageId:
                return mentionWithImageConfiguration(mention: mention, isCircle: false)
            }
        }
    }
    
    private func mentionWithImageConfiguration(mention: MentionObject, isCircle: Bool) -> UIContentConfiguration {
        var configuration = UIListContentConfiguration.subtitleCell()
        
        let imageSize = Constants.imageSize
        let imageCornerRadius = isCircle ? imageSize.width / 2 : Constants.imageCornerRadius
        
        configuration.imageProperties.cornerRadius = imageCornerRadius
        configuration.imageProperties.maximumSize = imageSize
        configuration.imageProperties.reservedLayoutSize = imageSize
        configuration.imageToTextPadding = Constants.imagePadding
        configuration.image = viewModel.image(for: mention, size: imageSize, radius: imageCornerRadius)
        
        configuration.text = mention.name
        configuration.textProperties.font = .bodyRegular
        configuration.textProperties.color = .textColor
        configuration.textToSecondaryTextVerticalPadding = Constants.textsVerticalPadding
        
        configuration.secondaryText = mention.description
        configuration.secondaryTextProperties.font = .relation2Regular
        configuration.secondaryTextProperties.color = .textSecondary
        return configuration
    }
    
    private func createNewObjectContentConfiguration() -> UIContentConfiguration {
        var configuration = UIListContentConfiguration.cell()
        configuration.text = "Create new object".localized
        configuration.textProperties.font = .uxTitle2Regular
        configuration.textProperties.color = .textSecondary
        
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
    
    func dismiss() {
        dismissAction?()
    }
}
