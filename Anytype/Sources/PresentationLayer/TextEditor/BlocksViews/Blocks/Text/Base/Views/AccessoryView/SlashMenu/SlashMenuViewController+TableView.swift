import UIKit

private enum SlashMenuConstants {
    static let cellHeight: CGFloat = 55
    static let dividerCellhHeight: CGFloat = 35
    static let separatorInsets = UIEdgeInsets(top: 0, left: 68, bottom: 0, right: 16)
    static let dividerSeparatorInsets = UIEdgeInsets(
        top: 0,
        left: UIScreen.main.bounds.width,
        bottom: 0,
        right: -UIScreen.main.bounds.width
    )
}

extension SlashMenuViewController: UITableViewDelegate {
    static let cellReuseId = NSStringFromClass(UITableViewCell.self)
    static let cellHeight: CGFloat = 55
    static let dividerCellhHeight: CGFloat = 35
    
    
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
            let childController = SlashMenuViewController(
                cellData: children.map { .action($0) },
                actionsHandler: actionsHandler,
                dismissHandler: dismissHandler
            )
            childController.title = type.title
            navigationController?.pushViewController(childController, animated: true)
        case let .action(action):
            actionsHandler.handle(action: action)
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
            return Self.cellHeight
        case .header:
            return Self.dividerCellhHeight
        }
    }
}

extension SlashMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)
        cell.accessoryType = .none
        
        let item = cellData[indexPath.row]
        switch item {
        case let .action(action):
            cell.separatorInset = SlashMenuConstants.separatorInsets
            cell.contentConfiguration = configurationFactory.configuration(displayData: action.displayData)
        case let .menu(itemType, children):
            cell.accessoryType = children.isEmpty ? .none : .disclosureIndicator
            cell.separatorInset = SlashMenuConstants.separatorInsets
            cell.contentConfiguration = configurationFactory.configuration(displayData: itemType.displayData)
        case let .header(title):
            cell.separatorInset = SlashMenuConstants.dividerSeparatorInsets
            cell.contentConfiguration = configurationFactory.dividerConfiguration(title: title)
        }

        return cell
    }
}
