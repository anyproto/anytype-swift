import SwiftUI
import Services
import Combine
import SwiftProtobuf

@MainActor
@Observable
final class SetFiltersSelectionViewModel {
    var state: SetFiltersSelectionViewState
    var condition: DataviewFilter.Condition {
        didSet { onConditionChanged?(condition) }
    }

    @ObservationIgnored
    var onConditionChanged: ((DataviewFilter.Condition) -> Void)?

    @ObservationIgnored
    private let filter: SetFilter
    @ObservationIgnored
    private let contentHandler: any SetFiltersContentHandlerProtocol
    @ObservationIgnored
    private let contentViewBuilder: SetFiltersContentViewBuilder
    @ObservationIgnored
    private let onApply: (SetFilter) -> Void

    @ObservationIgnored
    private weak var output: (any SetFiltersSelectionCoordinatorOutput)?
    
    init(
        data: SetFiltersSelectionData,
        contentViewBuilder: SetFiltersContentViewBuilder,
        output: (any SetFiltersSelectionCoordinatorOutput)?
    ) {
        self.filter = data.filter
        self.condition = filter.filter.condition
        self.output = output
        self.condition = filter.filter.condition
        self.contentViewBuilder = contentViewBuilder
        self.onApply = data.onApply
        self.contentHandler = SetFiltersContentHandler(
            filter: filter,
            onApply: onApply
        )
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
