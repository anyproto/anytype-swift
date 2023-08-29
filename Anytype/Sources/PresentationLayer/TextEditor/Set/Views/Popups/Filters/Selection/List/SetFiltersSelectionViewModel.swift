import SwiftUI
import Services
import Combine
import SwiftProtobuf

@MainActor
final class SetFiltersSelectionViewModel: ObservableObject {
    @Published var state: SetFiltersSelectionViewState
    @Published var condition: DataviewFilter.Condition
    
    private let filter: SetFilter
    private let contentHandler: SetFiltersContentHandlerProtocol
    private let contentViewBuilder: SetFiltersContentViewBuilder
    private let onApply: (SetFilter) -> Void
    
    private weak var output: SetFiltersSelectionCoordinatorOutput?
    
    init(
        filter: SetFilter,
        output: SetFiltersSelectionCoordinatorOutput?,
        contentViewBuilder: SetFiltersContentViewBuilder,
        onApply: @escaping (SetFilter) -> Void
    ) {
        self.filter = filter
        self.condition = filter.filter.condition
        self.output = output
        self.condition = filter.filter.condition
        self.contentViewBuilder = contentViewBuilder
        self.contentHandler = SetFiltersContentHandler(
            filter: filter,
            onApply: onApply
        )
        self.onApply = onApply
        self.state = filter.filter.condition.hasValues ? .content : .empty
    }

    func headerView() -> AnyView {
        contentViewBuilder.buildHeader(
            output: output,
            onConditionChanged: { [weak self] condition in
                self?.updateState(with: condition)
            }
        )
    }
    
    func contentView() -> AnyView {
        contentViewBuilder.buildContentView(
            setSelectionModel: self,
            onSelect: { [contentHandler] ids in
                contentHandler.handleSelectedIds(ids)
            },
            onApplyText: { [contentHandler] in
                contentHandler.handleText($0)
            },
            onApplyCheckbox: { [contentHandler] in
                contentHandler.handleCheckbox($0)
            },
            onApplyDate: { [contentHandler] in
                contentHandler.handleDate($0)
            }
        )
    }
    
    func handleEmptyValue() {
        contentHandler.handleEmptyValue()
    }
    
    func isCompactPresentationMode() -> Bool {
        contentViewBuilder.compactPresentationMode() || state == .empty
    }
    
    private func updateState(with condition: DataviewFilter.Condition) {
        self.condition = condition
        self.state = condition.hasValues ? .content : .empty
        contentHandler.updateCondition(condition)
    }
}

extension SetFiltersSelectionViewModel {
    enum Constants {
        static let emptyStateHeight: CGFloat = 150
        static let textStateHeight: CGFloat = 220
        static let checkboxStateHeight: CGFloat = 250
    }
}
