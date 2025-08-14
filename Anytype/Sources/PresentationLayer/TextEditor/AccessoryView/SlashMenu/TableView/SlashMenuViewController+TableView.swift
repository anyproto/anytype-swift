import UIKit

private enum SlashMenuConstants {
    static let cellHeight: CGFloat = 44
    static let dividerCellhHeight: CGFloat = 35
    static let separatorInsets = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 16)
    static let relationSeparatorInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    @MainActor
    static let dividerSeparatorInsets = UIEdgeInsets(
        top: 0,
        left: UIScreen.main.bounds.width,
        bottom: 0,
        right: -UIScreen.main.bounds.width
    )
}

extension SlashMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch cellData[indexPath.row] {
        case .header:
            return false
        case .action, .menu:
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cellData[indexPath.row] {
        case let .menu(type, children):
            guard !children.isEmpty else { return }
            
            AnytypeAnalytics.instance().logClickSlashMenu(type: type)

            let childCellData: [SlashMenuCellData] = children.map { .action($0) }
            
            let childController = SlashMenuAssembly.menuController(
                cellData: childCellData,
                topBarTitle: type.title,
                viewModel: viewModel,
                dismissHandler: dismissHandler
            )
            navigationController?.pushViewController(childController, animated: true)
        case let .action(action):
            viewModel.handle(action)
            dismissHandler?()
        case .header:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = cellData[indexPath.row]
        switch item {
        case .action, .menu:
            return SlashMenuConstants.cellHeight
        case .header:
            return SlashMenuConstants.dividerCellhHeight
        }
    }
}

extension SlashMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        let item = cellData[indexPath.row]
        switch item {
        case let .action(action):
            switch action.displayData {
            case let .titleDisplayData(displayData):
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.titleSubtitleReuseCellId, for: indexPath)
                if case .relations = action {
                    cell.separatorInset = SlashMenuConstants.relationSeparatorInsets
                } else {
                    cell.separatorInset = SlashMenuConstants.separatorInsets
                }
                cell.contentConfiguration = configurationFactory.configuration(displayData: displayData)
            case let .relationDisplayData(relation):
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.relationReuseCellId, for: indexPath)
                cell.separatorInset = SlashMenuConstants.relationSeparatorInsets
                cell.contentConfiguration = configurationFactory.configuration(relation: relation)
            }
        case let .menu(itemType, children):
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.titleSubtitleReuseCellId, for: indexPath)
            cell.accessoryType = children.isEmpty ? .none : .disclosureIndicator
            cell.separatorInset = SlashMenuConstants.separatorInsets
            cell.contentConfiguration = configurationFactory.configuration(displayData: itemType.displayData)
        case let .header(title):
            cell = tableView.dequeueReusableCell(withIdentifier: Constants.headerReuseCellId, for: indexPath)
            cell.separatorInset = SlashMenuConstants.dividerSeparatorInsets
            cell.contentConfiguration = configurationFactory.dividerConfiguration(title: title)
        }
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = .Background.highlightedMedium
        cell.selectedBackgroundView = bgColorView
        cell.accessoryType = .none

        return cell
    }
}
