import Foundation
import BlocksModels
import Combine

@MainActor
final class WidgetTypeViewModel: ObservableObject {
    
    private let internalModel: WidgetTypeInternalViewModelProtocol
    
    private var subscriptions: [AnyCancellable] = []
    @Published var rows: [WidgetTypeRowView.Model] = []
    
    init(internalModel: WidgetTypeInternalViewModelProtocol) {
        self.internalModel = internalModel
        
        internalModel.statePublisher
            .receiveOnMain()
            .compactMap { $0 }
            .sink { [weak self] state in
                self?.setupRows(state: state)
            }
            .store(in: &subscriptions)
    }
    
    private func setupRows(state: WidgetTypeState) {
        let availableTypes = state.source.availableWidgetLayout
        rows = availableTypes.map { type in
            return WidgetTypeRowView.Model(
                title: type.title,
                description: type.description,
                image: type.image,
                isSelected: type == state.layout,
                onTap: { [weak self] in
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
