import SwiftUI
import BlocksModels
import Combine
import SwiftProtobuf
import UIKit

final class SetFiltersSearchViewModel: ObservableObject {
    @Published var state: SetFiltersSearchViewState {
        didSet {
            if oldValue != state {
                updateLayout()
            }
        }
    }
    
    let headerViewModel: SetFiltersSearchHeaderViewModel
    let onApply: (SetFilter) -> Void
    
    private let filter: SetFilter
    private var condition: DataviewFilter.Condition
    private let searchViewBuilder: SetFiltersSearchViewBuilder
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
        self.searchViewBuilder = SetFiltersSearchViewBuilder(filter: filter)
        self.onApply = onApply
        self.condition = filter.filter.condition
        self.state = filter.filter.condition.hasValues ? .content : .empty
        self.headerViewModel = SetFiltersSearchHeaderViewModel(filter: filter, router: router)
        self.setup()
        self.updateLayout()
    }
    
    @ViewBuilder
    func makeContentView() -> some View {
        switch filter.conditionType {
        case .selected:
            searchViewBuilder.buildSearchView(
                onSelect: { [weak self] ids in
                    self?.handleSelectedIds(ids)
                }
            )
        case .text, .number:
            SetFiltersTextView(
                viewModel: SetFiltersTextViewModel(
                    filter: filter,
                    onApplyText: { [weak self] in
                        self?.handleText($0)
                    },
                    onKeyboardHeightChange: { [weak self] height in
                        self?.keyboardHeight = height
                        // fix simultaneous update of popup height and content
                        DispatchQueue.main.async {
                            self?.updateLayout()
                        }
                    }
                )
            )
        case .checkbox:
            EmptyView()
        }
    }
    
    func handleSelectedIds(_ ids: [String]) {
        handleValue(ids.protobufValue)
    }
    
    func handleText(_ text: String) {
        switch filter.conditionType {
        case .number:
            if let double = Double(text) {
                handleValue(double.protobufValue)
            }
        default:
            handleValue(text.protobufValue)
        }
    }
    
    func handleEmptyValue() {
        switch filter.conditionType {
        case .selected:
            handleSelectedIds([])
        case .number:
            handleText("0")
        case .text:
            handleText("")
        case .checkbox:
            break
        }
    }
    
    private func handleValue(_ value: SwiftProtobuf.Google_Protobuf_Value) {
        let filter = filter.updated(
            filter: filter.filter.updated(
                condition: condition,
                value: value
            )
        )
        onApply(filter)
    }
    
    private func setup() {
        headerViewModel.onConditionChanged = { [weak self] condition in
            self?.updateState(with: condition)
        }
    }
    
    private func updateState(with condition: DataviewFilter.Condition) {
        self.condition = condition
        self.state = condition.hasValues ? .content : .empty
    }
    
    private func updateLayout() {
        guard condition.hasValues else {
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

extension SetFiltersSearchViewModel: AnytypePopupViewModelProtocol {
    
    func makeContentView() -> UIViewController {
        UIHostingController(
            rootView: SetFiltersSearchView(content: makeContentView)
                .environmentObject(self)
        )
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
    
}

extension SetFiltersSearchViewModel {
    enum Constants {
        static let emptyStateHeight: CGFloat = 150
        static let textStateHeight: CGFloat = 220
        static let checkboxStateHeight: CGFloat = 250
    }
}
