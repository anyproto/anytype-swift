import Foundation
import Services

extension WidgetTypeRowView.Model {
    init(layout: BlockWidget.Layout, isSelected: Bool, onTap: @escaping () -> Void) {
        self = WidgetTypeRowView.Model(
            title: layout.title,
            description: layout.description,
            image: layout.image,
            isSelected: isSelected,
            onTap: onTap
        )
    }
}

private extension BlockWidget.Layout {
    
    var title: String {
        switch self {
        case .link:
            return Loc.Widgets.Layout.Link.title
        case .tree:
            return Loc.Widgets.Layout.Tree.title
        case .list:
            return Loc.Widgets.Layout.List.title
        case .compactList:
            return Loc.Widgets.Layout.CompactList.title
        }
    }
    
    var description: String {
        switch self {
        case .link:
            return Loc.Widgets.Layout.Link.description
        case .tree:
            return Loc.Widgets.Layout.Tree.description
        case .list:
            return Loc.Widgets.Layout.List.description
        case .compactList:
            return Loc.Widgets.Layout.CompactList.description
        }
    }
    
    var image: ImageAsset {
        switch self {
        case .link:
            return .Widget.Preview.link
        case .tree:
            return .Widget.Preview.tree
        case .list:
            return .Widget.Preview.list
        case .compactList:
            return .Widget.Preview.compactList
        }
    }
}

