import SwiftUI
import Services
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
    @Published var condition: DataviewFilter.Condition
    
    let headerViewModel: SetFiltersSelectionHeaderViewModel
    let onApply: (SetFilter) -> Void
    
    private let spaceId: String
    private let filter: SetFilter
    private let contentViewBuilder: SetFiltersContentViewBuilder
    private let contentHandler: SetFiltersContentHandlerProtocol
    private let router: EditorSetRouterProtocol
    
    private var keyboardHeight: CGFloat = 0
    
    private(set) var popupLayout: AnytypePopupLayoutType = .fullScreen {
        didSet {
            popup?.updateLayout(false)
        }
    }
    private weak var popup: AnytypePopupProxy?
    
    init(
        spaceId: String,
        filter: SetFilter,
        router: EditorSetRouterProtocol,
        newSearchModuleAssembly: NewSearchModuleAssemblyProtocol,
        onApply: @escaping (SetFilter) -> Void
    ) {
        self.spaceId = spaceId
        self.filter = filter
        self.router = router
        self.condition = filter.filter.condition
        self.contentViewBuilder = SetFiltersContentViewBuilder(
            spaceId: spaceId,
            filter: filter,
            newSearchModuleAssembly: newSearchModuleAssembly
        )
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
            router: router,
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
            onKeyboardHeightChange: { [weak self] height in
                self?.keyboardHeight = height
                self?.updateLayout()
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
        self.condition = condition
        self.state = condition.hasValues ? .content : .empty
        contentHandler.updateCondition(condition)
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
        case .selected, .date:
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
            rootView: SetFiltersSelectionView(viewModel: self, content: makeContentView)
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
