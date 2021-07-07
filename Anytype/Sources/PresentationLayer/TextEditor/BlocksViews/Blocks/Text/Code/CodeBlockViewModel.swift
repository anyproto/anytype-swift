import Combine
import UIKit
import BlocksModels

final class CodeBlockViewModel: BaseBlockViewModel {
    private enum Constants {
        static let codeLanguageFieldName = "lang"
    }
    
    private var serialQueue = DispatchQueue(label: "BlocksViews.Text.Base.SerialQueue")

    private var subscriptions: Set<AnyCancellable> = []

    weak var codeBlockView: CodeBlockViewInteractable?
    private let listService: BlockActionsServiceList = .init()

    // MARK: View state
    @Published private(set) var shouldResignFirstResponder = PassthroughSubject<Void, Never>()
    @Published private(set) var textViewUpdate: TextViewUpdate?
    @Published var focus: BlockFocusPosition?
    @Published var codeLanguage: String? = "Swift"

    override init(_ block: BlockActiveRecordProtocol, delegate: BlockDelegate?, actionHandler: EditorActionHandlerProtocol, router: EditorRouterProtocol) {
        super.init(block, delegate: delegate, actionHandler: actionHandler, router: router)
        self.setupSubscribers()

        if let lang = block.blockModel.information.fields[Constants.codeLanguageFieldName]?.stringValue {
            codeLanguage = lang
        }
    }

    // MARK: - Subclassing accessors

    override func makeContentConfiguration() -> UIContentConfiguration {
        var configuration = CodeBlockContentConfiguration(self)
        configuration.viewModel = self
        return configuration
    }
    
    override func makeContextualMenu() -> ContextualMenu {
        ContextualMenu(
            title: "",
            children: [
                .init(action: .addBlockBelow),
                .init(action: .turnIntoPage),
                .init(action: .delete),
                .init(action: .duplicate)
            ]
        )
    }

    func setCodeLanguage(_ language: String) {
        guard let contextId = block.container?.rootId else { return }

        let blockFields = BlockFields(blockId: blockId, fields: [Constants.codeLanguageFieldName: language])
        listService.setFields(contextID: contextId, blockFields: [blockFields]).sink { _ in } receiveValue: { _ in }.store(in: &subscriptions)
    }

    func becomeFirstResponder() {
        blockDelegate?.becomeFirstResponder(for: block.blockModel)
    }
}

// MARK: - Setup

private extension CodeBlockViewModel {

    func setupSubscribers() {
        // Update text view in code block
        block.didChangePublisher().receive(on: serialQueue)
            .map { [weak self] _ -> BlockText? in
                let value = self?.block.blockModel.information

                if let lang = value?.fields[Constants.codeLanguageFieldName]?.stringValue {
                    self?.codeLanguage = lang
                    self?.codeBlockView?.languageDidChange(language: lang)
                }
                switch value?.content {
                case let .text(value): return value
                default: return nil
                }
            }
            .safelyUnwrapOptionals()
            .receiveOnMain()
            .map { textContent -> TextViewUpdate in
                let blockColor = MiddlewareColorConverter.asUIColor(name: textContent.color, background: false)
                return .payload(
                    .init(
                        attributedString: textContent.attributedText,
                        auxiliary: .init(textAlignment: .left, tertiaryColor: blockColor)
                    )
                )
            }
            .sink { [weak self] textViewUpdate in
                self?.textViewUpdate = textViewUpdate
            }.store(in: &self.subscriptions)
    }
}

// MARK: - Set Focus

extension CodeBlockViewModel {
    func set(focus: BlockFocusPosition?) {
        self.focus = focus
    }
}

// MARK: - TextViewUserInteractionProtocol

extension CodeBlockViewModel: TextViewUserInteractionProtocol {
    func didReceiveAction(_ action: CustomTextView.UserAction) -> Bool {
        switch action {
        case .showStyleMenu:
            router.showStyleMenu(information: block.blockModel.information)
        case .showMultiActionMenuAction:
            self.shouldResignFirstResponder.send()
            actionHandler.handleAction(.textView(action: action, activeRecord: block), info: block.blockModel.information)
        case .changeText, .keyboardAction, .changeTextStyle, .changeCaretPosition:
            actionHandler.handleAction(.textView(action: action, activeRecord: block), info: block.blockModel.information)
        case .shouldChangeText:
            break
        case .changeTextForStruct(_):
            break
        }
        return true
    }
}

// MARK: - Debug

extension CodeBlockViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        guard case let .text(text) = information.content else {
            return "id: \(blockId) text block with wrong content type!!! See BlockInformation"
        }
        return "id: \(blockId)\ntext: \(text.attributedText.string.prefix(10))...\ntype: \(text.contentType)"
    }
}
