import Foundation
import BlocksModels
import SwiftUI
import Combine
import FloatingPanel

final class TextRelationDetailsViewModel: ObservableObject {
    
    var layoutPublisher: Published<FloatingPanelLayout>.Publisher { $layout }
    @Published private var layout: FloatingPanelLayout = FixedHeightPopupLayout(height: 0)
    
    var onDismiss: () -> Void = {}
    
    @Published var value: String = "" {
        didSet {
            actionButtonViewModel?.text = value
        }
    }
    
    @Published var height: CGFloat = 0 {
        didSet {
            layout = FixedHeightPopupLayout(height: height + keyboardHeight)
        }
    }
    
    let type: TextRelationDetailsViewType
    
    let actionButtonViewModel: TextRelationActionButtonViewModel?
    
    private let relation: Relation
    private let service: TextRelationDetailsServiceProtocol
        
    private var cancellable: AnyCancellable?
    
    private var keyboardListener: KeyboardEventsListnerHelper?
    private var keyboardHeight: CGFloat = 0
    
    init(
        value: String,
        type: TextRelationDetailsViewType,
        relation: Relation,
        service: TextRelationDetailsServiceProtocol,
        actionButtonViewModel: TextRelationActionButtonViewModel?
    ) {
        self.value = value
        self.type = type
        self.actionButtonViewModel = actionButtonViewModel
        self.relation = relation
        self.service = service
        
        cancellable = self.$value
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveValue()
            }
        
        setupKeyboardListener()
    }
    
    var title: String {
        relation.name
    }
    
}

extension TextRelationDetailsViewModel: RelationDetailsViewModelProtocol {
    
    func makeViewController() -> UIViewController {
        TextRelationDetailsViewController(viewModel: self)
    }
}

extension TextRelationDetailsViewModel: RelationEditingViewModelProtocol {
    
    func saveValue() {
        service.saveRelation(value: value, key: relation.id, textType: type)
    }
    
    func makeView() -> AnyView {
        EmptyView().eraseToAnyView()
    }
    
}

private extension TextRelationDetailsViewModel {
    
    func setupKeyboardListener() {
        let showAction: KeyboardEventsListnerHelper.Action = { [weak self] notification in
            guard
                let keyboardRect = notification.localKeyboardRect(for: UIResponder.keyboardFrameEndUserInfoKey)
            else { return }
            
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
        self.keyboardHeight = keyboardHeight
        layout = FixedHeightPopupLayout(height: height + keyboardHeight)
    }
    
}
