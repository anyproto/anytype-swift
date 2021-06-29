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

    @Published private(set) var textViewUpdate: TextViewUpdate?
    
    // MARK: - Placeholder

    lazy private var placeholder: NSAttributedString = {
        let text: NSString = "Untitled"
        let attributedString: NSMutableAttributedString = .init(string: text as String)
        let attributes: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.lightGray, .font: UIFont.preferredFont(forTextStyle: .title1)]
        attributedString.setAttributes(attributes, range: .init(location: 0, length: text.length))
        return attributedString
    }()
    
    // MARK: - Initialization
    
    override init(_ block: BlockActiveRecordProtocol, delegate: BaseBlockDelegate?, actionHandler: NewBlockActionHandler?, router: EditorRouterProtocol) {
        super.init(block, delegate: delegate, actionHandler: actionHandler, router: router)
        self.setupSubscribers()
    }

    // MARK: - Setup

    private func setupSubscribers() {
        self.$toViewTitle.removeDuplicates().receiveOnMain().sink { [weak self] (value) in
            self?.textViewUpdate = .text(value)
        }.store(in: &self.subscriptions)
    }
    
    // MARK: Subclassing / Events
    override func onIncoming(event: PageBlockViewEvents) {
        switch event {
        case .pageDetailsViewModelDidSet:
            /// Here we must subscribe on values from this model and filter values.
            /// We only want values equal to details.
            ///
            self.pageDetailsViewModel?
                .wholeDetailsPublisher
                .map { $0.name }
                .sink(receiveValue: { [weak self] (value) in
                value.flatMap({ self?.toViewTitle = $0 })
            }).store(in: &self.subscriptions)

            self.toModelTitleSubject.notableError().flatMap({ [weak self] value in
                self?.pageDetailsViewModel?.update(
                    details: [
                        .name: DetailsEntry(
                            value: value
                        )
                    ]
                ) ?? .empty()
            }).sinkWithDefaultCompletion("PageBlocksViews title setDetails") {}
            .store(in: &self.subscriptions)
        }
    }
}

// MARK: - TextViewEvents
extension PageTitleViewModel: TextViewUserInteractionProtocol {
    func didReceiveAction(_ action: CustomTextView.UserAction) {
        actionHandler?.handleAction(.textView(action: action, activeRecord: block), model: block.blockModel)
    }
}
