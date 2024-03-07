import Foundation
import Services
import SwiftUI
import Combine
import FloatingPanel

@MainActor //
final class TextRelationDetailsViewModel: ObservableObject, TextRelationDetailsViewModelProtocol {
    weak var viewController: TextRelationDetailsViewController?
    
    private weak var popup: AnytypePopupProxy?

    private(set) var popupLayout: AnytypePopupLayoutType = .intrinsic {
        didSet {
            popup?.updateLayout(false)
        }
    }
    
    @Published var value: String = ""
    
    var isEditable: Bool {
        return relation.isEditable
    }
    
    var title: String {
        relation.name
    }
    
    let type: TextRelationViewType
    
    let actionsViewModel: [TextRelationActionViewModelProtocol]
    
    private let objectId: String
    private let relation: Relation
    private let service: TextRelationEditingServiceProtocol
    private let analyticsType: AnalyticsEventsRelationType
    private var cancellable: AnyCancellable?
    
    private var keyboardListener: KeyboardEventsListnerHelper?
    
    // MARK: - Initializers
    
    init(
        objectId: String,
        value: String,
        type: TextRelationViewType,
        relation: Relation,
        service: TextRelationEditingServiceProtocol,
        analyticsType: AnalyticsEventsRelationType,
        actionsViewModel: [TextRelationActionViewModelProtocol] = []
    ) {
        self.objectId = objectId
        self.value = value
        self.type = type
        self.relation = relation
        self.service = service
        self.analyticsType = analyticsType
        self.actionsViewModel = actionsViewModel
        
        cancellable = self.$value
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveValue()
            }
        
        setupKeyboardListener()
        handleValueUpdate(value: value)
    }
    
    func updateValue(_ text: String) {
        value = text
        handleValueUpdate(value: value)
    }
    
    func onWillDisappear() {
        guard isEditable else { return }
        AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: value.isEmpty, type: analyticsType)
    }
}

extension TextRelationDetailsViewModel {
    
    func updatePopupLayout(_ layoutGuide: UILayoutGuide) {
        self.popupLayout = .adaptiveTextRelationDetails(layoutGuide: layoutGuide)
    }
    
}

extension TextRelationDetailsViewModel: AnytypePopupViewModelProtocol {
    
    func makeContentView() -> UIViewController {
        let vc = TextRelationDetailsViewController(viewModel: self)
        self.viewController = vc
        return vc
    }
    
    func onPopupInstall(_ popup: AnytypePopupProxy) {
        self.popup = popup
    }
}

private extension TextRelationDetailsViewModel {
    
    func saveValue() {
        service.saveRelation(objectId: objectId, value: value, key: relation.key, textType: type)
        logEvent()
    }
    
    func setupKeyboardListener() {
        let showAction: KeyboardEventsListnerHelper.Action = { [weak self] event in
            guard let keyboardRect = event.endFrame else { return }
            
            self?.adjustViewHeightBy(keyboardHeight: keyboardRect.height)
        }

        let willHideAction: KeyboardEventsListnerHelper.Action = { [weak self] _ in
            self?.adjustViewHeightBy(keyboardHeight: 0)
        }

        self.keyboardListener = KeyboardEventsListnerHelper(
            willShowAction: showAction,
            willChangeFrame: showAction,
            willHideAction: willHideAction
        )
    }
    
    func adjustViewHeightBy(keyboardHeight: CGFloat) {
        viewController?.keyboardDidUpdateHeight(keyboardHeight)
        popup?.updateLayout(true)
    }
    
    func handleValueUpdate(value: String) {
        for actionViewModel in actionsViewModel {
            actionViewModel.inputText = value
        }
    }
    
    private func logEvent() {
        switch type {
        case .url:
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.relationUrlEditMobile)
        default:
            break
        }
    }
}
