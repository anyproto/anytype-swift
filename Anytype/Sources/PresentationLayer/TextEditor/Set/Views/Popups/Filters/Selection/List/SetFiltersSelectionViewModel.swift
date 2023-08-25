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
    
    init(
        filter: SetFilter,
        contentViewBuilder: SetFiltersContentViewBuilder,
        onApply: @escaping (SetFilter) -> Void
    ) {
        self.filter = filter
        self.condition = filter.filter.condition
        self.contentViewBuilder = contentViewBuilder
        self.contentHandler = SetFiltersContentHandler(filter: filter, onApply: onApply)
        self.onApply = onApply
        self.state = filter.filter.condition.hasValues ? .content : .empty
    }

    
    func contentView() -> some View {
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
            },
            onKeyboardHeightChange: { [weak self] _ in
            }
        )
    }
    
    func handleEmptyValue() {
        contentHandler.handleEmptyValue()
    }
    
    private func updateState(with condition: DataviewFilter.Condition) {
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
