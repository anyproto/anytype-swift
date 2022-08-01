import SwiftUI
import BlocksModels
import Combine
import SwiftProtobuf

final class SetFiltersSelectionViewModel: ObservableObject {
    @Published var state: SetFiltersSelectionViewState {
        didSet {
            if oldValue != state {
                updateLayout()
            }
        }
    }
    
    let headerViewModel: SetFiltersSelectionHeaderViewModel
    let onApply: (SetFilter) -> Void
    
    private let filter: SetFilter
    private let contentViewBuilder: SetFiltersContentViewBuilder
    private let contentHandler: SetFiltersContentHandlerProtocol
    private let router: EditorRouterProtocol
    
    private var keyboardHeight: CGFloat = 0
    
    private(set) var popupLayout: AnytypePopupLayoutType = .fullScreen {
        didSet {
            popup?.updateLayout(true)
        }
    }
    private weak var popup: AnytypePopupProxy?
    
    init(
        filter: SetFilter,
        router: EditorRouterProtocol,
        onApply: @escaping (SetFilter) -> Void
    ) {
        self.filter = filter
        self.router = router
        self.contentViewBuilder = SetFiltersContentViewBuilder(filter: filter)
        self.contentHandler = SetFiltersContentHandler(filter: filter, onApply: onApply)
        self.onApply = onApply
        self.state = filter.filter.condition.hasValues ? .content : .empty
        self.headerViewModel = SetFiltersSelectionHeaderViewModel(filter: filter, router: router)
        self.setup()
        self.updateLayout()
    }
    
    @ViewBuilder
    func makeContentView() -> some View {
        contentViewBuilder.buildContentView(
            onSelect: { [contentHandler] ids in
                contentHandler.handleSelectedIds(ids)
            },
            onApplyText: { [contentHandler] in
                contentHandler.handleText($0)
            },
            onApplyCheckbox: { [contentHandler] in
                contentHandler.handleCheckbox($0)
            },
            onKeyboardHeightChange: { [weak self] height in
                self?.keyboardHeight = height
                // fix simultaneous update of popup height and content
                DispatchQueue.main.async {
                    self?.updateLayout()
                }
            }
        )
    }
    
    func handleEmptyValue() {
        contentHandler.handleEmptyValue()
    }
    
    private func setup() {
        headerViewModel.onConditionChanged = { [weak self] condition in
            self?.updateState(with: condition)
        }
    }
    
    private func updateState(with condition: DataviewFilter.Condition) {
        contentHandler.updateCondition(condition)
        self.state = condition.hasValues ? .content : .empty
    }
    
    private func updateLayout() {
        guard state == .content else {
            popupLayout = .constantHeight(height: Constants.emptyStateHeight, floatingPanelStyle: false)
            return
        }
        switch filter.conditionType {
        case .text, .number:
            popupLayout = .constantHeight(
                height: keyboardHeight + Constants.textStateHeight,
                floatingPanelStyle: false,
                needBottomInset: false
            )
        case .selected:
            popupLayout = .fullScreen
        case .checkbox:
            popupLayout = .constantHeight(height: Constants.checkboxStateHeight, floatingPanelStyle: false)
        }
    }
}

// MARK: - AnytypePopupViewModelProtocol

extension SetFiltersSelectionViewModel: AnytypePopupViewModelProtocol {
    
    func makeContentView() -> UIViewController {
        UIHostingController(
            rootView: SetFiltersSelectionView(content: makeContentView)
                .environmentObject(self)
        )
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
}

extension SetFiltersSelectionViewModel {
    enum Constants {
        static let emptyStateHeight: CGFloat = 150
        static let textStateHeight: CGFloat = 220
        static let checkboxStateHeight: CGFloat = 250
    }
}
