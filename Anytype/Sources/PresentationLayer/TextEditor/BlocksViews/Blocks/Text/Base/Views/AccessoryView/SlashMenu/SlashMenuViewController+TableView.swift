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
            return Self.cellHeight
        case .sectionDivider:
            return Self.dividerCellhHeight
        }
    }
}

extension SlashMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)
        cell.accessoryType = .none
        
        let item = self.items[indexPath.row]
        switch item {
        case let .action(action):
            cell.separatorInset = SlashMenuConstants.separatorInsets
            cell.contentConfiguration = configurationFactory.configuration(displayData: action.displayData)
        case let .menu(itemType, children):
            cell.accessoryType = children.isEmpty ? .none : .disclosureIndicator
            cell.separatorInset = SlashMenuConstants.separatorInsets
            cell.contentConfiguration = configurationFactory.configuration(displayData: itemType.displayData)
        case let .sectionDivider(divider):
            cell.separatorInset = SlashMenuConstants.dividerSeparatorInsets
            cell.contentConfiguration = configurationFactory.dividerConfiguration(title: divider)
        }

        return cell
    }
}
