import Foundation
import UIKit
import Combine
import os
import BlocksModels


/// ViewModel for type `.link()` with style `.page`
class PageTitleViewModel: PageBlockViewModel {
    // Maybe we need also input and output subscribers.
    // MAYBE PAGE BLOCK IS ORDINARY TEXT BLOCK?
    // We can't edit name of the block.
    // Add subscription on event.
    
    private var subscriptions: Set<AnyCancellable> = []
    private weak var textView: TextViewUpdatable?

    /// Points of truth.
    /// We could use it as input and output subscribers.
    /// For example, if user set value, it is going to `toModelTitle`.
    /// If value came from model, you set it to `toViewTitle`.
    @Published private var toViewTitle: String = "" // Maybe we should set here default value as "Untitled"

    /// Don't delete commented code.
    /// It is necessary to see what is wrong with it.
    /// We can't use `@Published` property, because its default value is `String.empty`.
    /// So, it will send value `String.empty` on new subscription. This is incorrect behaviour.
    /// It is better to `Passthrough` all data before user could change it.
    /// User could change data only when `View` has appeared.
    ///
    //        @Published private var toModelTitle: String = ""
    private var toModelTitleSubject: PassthroughSubject<String, Never> = .init()
    
    // MARK: - Placeholder
    lazy private var placeholder: NSAttributedString = {
        let text: NSString = "Untitled"
        let attributedString: NSMutableAttributedString = .init(string: text as String)
        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.lightGray, .font: UIFont.preferredFont(forTextStyle: .title1)]
        attributedString.setAttributes(attributes, range: .init(location: 0, length: text.length))
        return attributedString
    }()
    
    // MARK: - Initialization
    override init(_ block: BlockModel) {
        super.init(block)
        self.setupSubscribers()
    }

    // MARK: - Setup
    private func setupSubscribers() {
        self.$toViewTitle.removeDuplicates().receiveOnMain().sink { [weak self] (value) in
            self?.textView?.apply(update: .text(value))
        }.store(in: &self.subscriptions)
    }
    
    // MARK: Subclassing / Events
    override func onIncoming(event: PageBlockViewEvents) {
        switch event {
        case .pageDetailsViewModelDidSet:
            /// Here we must subscribe on values from this model and filter values.
            /// We only want values equal to details.
            ///
            self.pageDetailsViewModel?.wholeDetailsPublisher.map{ $0.name }
                .sink(receiveValue: { [weak self] (value) in
                value.flatMap({ self?.toViewTitle = $0.value })
            }).store(in: &self.subscriptions)

            self.toModelTitleSubject.notableError().flatMap({ [weak self] value in
                self?.pageDetailsViewModel?.update(details: [.name(.init(value: value))]) ?? .empty()
            }).sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    assertionFailure("PageBlocksViews title setDetails error has occured \(error)")
                }
            }, receiveValue: {}).store(in: &self.subscriptions)
        }
    }

    // MARK: Subclassing / Views
    override func makeUIView() -> UIView {
        func makeCoordinator() -> BlockTextViewCoordinator {
            let factory = BlockRestrictionsFactory()
            let restrictions = factory.makeRestrictions(for: information.content.type)
            let actionsHandler = BlockMenuActionsHandlerImp(marksPaneActionSubject: marksPaneActionSubject,
                                                            addBlockAndActionsSubject: toolbarActionSubject)
            let coordinator = BlockTextViewCoordinator(menuItemsBuilder: BlockActionsBuilder(restrictions: restrictions),
                                                       blockMenuActionsHandler: actionsHandler)
            return coordinator
        }

        let textView = BlockTextView()
        let placeholder = BlockTextView.Placeholder(text: nil, attributedText: self.placeholder, attributes: [:])
        textView.coordinator = makeCoordinator().configure(self)

        return PageTitleUIKitView().configured(textView: textView.configured(placeholder: placeholder))
    }
}

// MARK: - TextViewEvents
extension PageTitleViewModel: TextViewUserInteractionProtocol {
    func didReceiveAction(_ action: BlockTextView.UserAction) {
        switch action {
//        case let .addBlockAction(value):
//            switch value {
//            case .addBlock: self.send(userAction: .toolbars(.addBlock(.init(output: self.toolbarActionSubject))))
//            }
        
//        case .showMultiActionMenuAction(.showMultiActionMenu):
//            self.getUIKitViewModel().shouldResignFirstResponder()
//            self.send(actionsPayload: .textView(.init(model: self.getBlock(), action: .textView(action))))
            
        default: self.send(actionsPayload: .textView(.init(model: self.getBlock(), action: .textView(action))))
        }
    }
}
