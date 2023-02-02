import Foundation
import BlocksModels

final class WidgetTypeViewModel: ObservableObject {
    
    private var availableTypes: [BlockWidget.Layout]
    private let details: ObjectDetails
    private let internalModel: WidgetTypeInternalViewModelProtocol
    
    @Published var rows: [WidgetTypeRowView.Model] = []
    
    init(details: ObjectDetails, internalModel: WidgetTypeInternalViewModelProtocol) {
        self.details = details
        self.internalModel = internalModel
        self.availableTypes = details.availableWidgetLayout
        setupRows()
    }
    
    private func setupRows() {
        rows = availableTypes.map { type in
            return WidgetTypeRowView.Model(title: type.title, description: type.description, image: type.image, onTap: { [weak self] in
                self?.internalModel.onTap(layout: type)
            })
        }
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
        }
    }
}

private extension ObjectDetails {
    var availableWidgetLayout: [BlockWidget.Layout] {
        switch editorViewType {
        case .page:
           return [.tree, .link]
        case .set:
            return [.list, .link]
        case .favorite, .recent, .sets:
            return [.list, .tree]
        }
    }
}
