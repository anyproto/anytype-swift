import Combine
import UIKit
import BlocksModels
 
class TextBlockViewModel: BaseBlockViewModel {
    // MARK: - Private variables

    private let serialQueue = DispatchQueue(label: "BlocksViews.Text.Base.SerialQueue")

    private let service = BlockActionsServiceText()
    private var subscriptions: Set<AnyCancellable> = []
    private lazy var mentionsConfigurator = MentionsTextViewConfigurator { [weak self] pageId in
        guard let self = self else { return }
        self.router?.showPage(with: pageId)
    }

    // MARK: View state
    private(set) var shouldResignFirstResponder = PassthroughSubject<Void, Never>()
    @Published private(set) var textViewUpdate: TextViewUpdate?
    private(set) var setFocus = PassthroughSubject<BlockFocusPosition, Never>()
    
    override init(_ block: BlockActiveRecordModelProtocol, delegate: BaseBlockDelegate?, actionHandler: NewBlockActionHandler?, router: EditorRouterProtocol?) {
        super.init(block, delegate: delegate, actionHandler: actionHandler, router: router)

        setupSubscribers()
    }

    // MARK: - Subclassing accessors

    override func makeContentConfiguration() -> UIContentConfiguration {
        return TextBlockContentConfiguration(
            textViewDelegate: self,
            viewModel: self,
            blockActionHandler: actionHandler,
            mentionsConfigurator: mentionsConfigurator
        )
    }

    // MARK: - Contextual Menu
    
    override func makeContextualMenu() -> ContextualMenu {
        guard case let .text(text) = block.content else {
            return .init(title: "", children: [])
        }
        
        let actions: [ContextualMenuData] = {
            var result: [ContextualMenuData] = [
                .init(action: .addBlockBelow)
            ]
            
            guard text.contentType != .title else { return result }
            
            result.append(
                contentsOf: [
                    .init(action: .turnIntoPage),
                    .init(action: .delete),
                    .init(action: .duplicate),
                    .init(action: .style)
                ]
            )
            
            return result
        }()
        
        
        return .init(title: "", children: actions)
    }

    override func updateView() {
        refreshedTextViewUpdate()
    }
}

// MARK: - Methods called by View

extension TextBlockViewModel {

    func refreshedTextViewUpdate() {
        let block = self.block
        let information = block.blockModel.information

        switch information.content {
        case let .text(blockType):
            let attributedText = blockType.attributedText
            
            let alignment = information.alignment.asTextAlignment
            let blockColor = MiddlewareColorConverter.asUIColor(name: blockType.color, background: false)

            textViewUpdate = TextViewUpdate.payload(
                .init(
                    attributedString: attributedText,
                    auxiliary: .init(
                        textAlignment: alignment,
                        tertiaryColor: blockColor
                    )
                )
            )
        default: return
        }
    }
}


// MARK: - TextViewDelegate

extension TextBlockViewModel: TextViewDelegate {
    func willBeginEditing() {
        baseBlockDelegate?.willBeginEditing()
    }

    func didBeginEditing() {
        baseBlockDelegate?.didBeginEditing()
    }
    
    func changeFirstResponderState(_ change: TextViewFirstResponderChange) {
        baseBlockDelegate?.becomeFirstResponder(for: block.blockModel)
    }

    func sizeChanged() {
        baseBlockDelegate?.blockSizeChanged()
    }
}

// MARK: - Setup

private extension TextBlockViewModel {

    func setupSubscribers() {
        // ToView
        let alignmentPublisher = block.didChangeInformationPublisher()
            .map(\.alignment)
            .map { $0.asTextAlignment }
            .removeDuplicates()
            .safelyUnwrapOptionals()

        // We need it for Merge requests.
        // Maybe we should do it differently.
        // We change subscription on didChangePublisher to reflect changes ONLY from specific events like `Merge`.
        // If we listen `changeInformationPublisher()`, we will receive whole data from every change.
        let modelDidChangeOnMergePublisher = block.didChangePublisher()
            .receive(on: serialQueue)
            .map { [weak self] _ -> BlockText? in
                guard let value = self?.block.blockModel.information else { return nil }

                switch value.content {
                case let .text(value):
                    return value
                default:
                    return nil
                }
            }
            .safelyUnwrapOptionals()

        Publishers.CombineLatest(modelDidChangeOnMergePublisher, alignmentPublisher)
            .receiveOnMain()
            .map { value -> TextViewUpdate in
                let (text, alignment) = value
                let blockColor = MiddlewareColorConverter.asUIColor(name: text.color, background: false)
                return .payload(
                    .init(
                        attributedString: text.attributedText,
                        auxiliary: .init(textAlignment: alignment, tertiaryColor: blockColor)
                    )
                )
            }
            .sink { [weak self] (textViewUpdate) in
                guard let self = self else { return }
                self.textViewUpdate = textViewUpdate
            }.store(in: &self.subscriptions)
    }
}

// MARK: - Set Focus

extension TextBlockViewModel {
    func set(focus: BlockFocusPosition) {
        self.setFocus.send(focus)
    }
}

// MARK: - Actions Payload Legacy

extension TextBlockViewModel {    
    func onCheckboxTap(selected: Bool) {
        actionHandler?.handleAction(.checkbox(selected: selected), model: block.blockModel)
    }
    
    func onToggleTap(toggled: Bool) {
        actionHandler?.handleAction(.toggle, model: block.blockModel)
    }
    
}

// MARK: - TextViewUserInteractionProtocol

extension TextBlockViewModel: TextViewUserInteractionProtocol {
    
    func didReceiveAction(_ action: CustomTextView.UserAction) {
            switch action {
            case .showStyleMenu:
                router?.showStyleMenu(block: block.blockModel, viewModel: self)
            case .showMultiActionMenuAction:
                shouldResignFirstResponder.send()
                actionHandler?.handleAction(.textView(action: action, activeRecord: block), model: block.blockModel)
            case let .changeText(textView):
                mentionsConfigurator.configure(textView: textView)
                actionHandler?.handleAction(.textView(action: action, activeRecord: block), model: block.blockModel)
            case .keyboardAction, .changeTextStyle, .changeCaretPosition:
                actionHandler?.handleAction(.textView(action: action, activeRecord: block), model: block.blockModel)
            case let .shouldChangeText(range, replacementText, mentionsHolder):
                mentionsHolder.removeMentionIfNeeded(
                    replacementRange: range,
                    replacementText: replacementText
                )
            case let .showPage(pageId):
                actionHandler?.handleAction(.textView(action: .showPage(pageId), activeRecord: block), model: block.blockModel)
            }
        }
}

// MARK: - Debug

extension TextBlockViewModel: CustomDebugStringConvertible {
    
    var debugDescription: String {
        guard case let .text(text) = information.content else {
            return "id: \(blockId) text block with wrong content type!!! See BlockInformation"
        }
        let address = String(format: "%p", unsafeBitCast(self, to: Int.self))

        return "\(address)\nid: \(blockId)\ntext: \(text.attributedText.string.prefix(20))...\ntype: \(text.contentType)\n"
    }
    
}
