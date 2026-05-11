import Foundation
import Services

extension BlockWidgetInfo {

    /// Set/Type source rendered as `.view` / `.list` / `.compactList`.
    /// Routing mirrors `HomeWidgetSubmoduleView.viewForObject`.
    var isSetTypeWidget: Bool {
        guard case let .object(details) = source else { return false }
        let validViewType = details.editorViewType == .list || details.editorViewType == .type
        let validLayout: [BlockWidget.Layout] = [.view, .list, .compactList]
        return validViewType && validLayout.contains(fixedLayout)
    }

    /// Object source with `.page` editor type rendered as `.tree`.
    /// Routing mirrors `HomeWidgetSubmoduleView.viewForObject`.
    var isTreeObjectWidget: Bool {
        guard case let .object(details) = source else { return false }
        return details.editorViewType == .page && fixedLayout == .tree
    }
}
