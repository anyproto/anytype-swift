import UIKit
import BlocksModels
import SwiftUI

final class EditorAccessoryViewModel {
    typealias MenuItemType = EditorAccessoryView.MenuItem.MenuItemType
    typealias TypeItem = ChangeTypeAccessoryItemViewModel.Item

    var block: BlockModelProtocol!
    
    weak var customTextView: CustomTextView? {
        didSet {
            updateAccessoryViewState()
        }
    }
    weak var delegate: EditorAccessoryViewDelegate?

    @Published private(set) var isTypesViewVisible: Bool = false
    @Published private(set) var isChangeTypeAvailable: Bool = false
    @Published private(set) var supportedTypes = [TypeItem]()

    private let document: BaseDocumentProtocol
    private let handler: EditorActionHandlerProtocol
    private let router: EditorRouter
    private let searchService: SearchServiceProtocol
    
    init(
        router: EditorRouter,
        handler: EditorActionHandlerProtocol,
        searchService: SearchServiceProtocol,
        document: BaseDocumentProtocol
    ) {
        self.router = router
        self.handler = handler
        self.searchService = searchService
        self.document = document

        fetchSupportedTypes()
    }
    
    func handleMenuItemTap(_ menuItem: MenuItemType) {
        guard let textView = customTextView?.textView, let delegate = delegate else {
            return
        }

        switch menuItem {
        case .mention:
            textView.insertStringAfterCaret(
                TextTriggerSymbols.mention(prependSpace: shouldPrependSpace(textView: textView))
            )

            handler.handleActionForFirstResponder(
                .textView(
                    action: .changeText(textView.attributedText),
                    block: block
                )
            )

            delegate.showMentionsView()
        case .slash:
            textView.insertStringAfterCaret(TextTriggerSymbols.slashMenu)

            handler.handleActionForFirstResponder(
                .textView(
                    action: .changeText(textView.attributedText),
                    block: block
                )
            )

            delegate.showSlashMenuView()
        case .style:
            router.showStyleMenu(information: block.information)
        }
    }

    func handleDoneButtonTap() {
        UIApplication.shared.hideKeyboard()
    }

    func toogleChangeTypeState() {
        isTypesViewVisible.toggle()
    }

    func textDidChange() {
        updateAccessoryViewState()
    }

    private func updateAccessoryViewState() {
        let isDocumentEmpty = document.isDocumentEmpty

        if isTypesViewVisible && !isDocumentEmpty {
            isTypesViewVisible = false
        }

        isChangeTypeAvailable = isDocumentEmpty
    }
    
    private func shouldPrependSpace(textView: UITextView) -> Bool {
        let carretInTheBeginingOfDocument = textView.isCarretInTheBeginingOfDocument
        let haveSpaceBeforeCarret = textView.textBeforeCaret?.last == " "
        
        return !(carretInTheBeginingOfDocument || haveSpaceBeforeCarret)
    }

    private func fetchSupportedTypes() {
        let supportedTypes = searchService.searchObjectTypes(text: "")?.map { object -> TypeItem in
            let emoji = IconEmoji(object.iconEmoji).map { ObjectIconImage.icon(.emoji($0)) } ??  ObjectIconImage.image(UIImage())
            return TypeItem(
                id: object.id,
                title: object.name,
                image: emoji,
                action: { [weak handler] in handler?.setObjectTypeUrl(object.id) }
            )
        }

        self.supportedTypes = supportedTypes!
    }
}

private extension BaseDocumentProtocol {
    var isDocumentEmpty: Bool {
        print("-_- flattenBlocks content \(flattenBlocks.map { $0.information.content })")

        let isExpectionTypesExists = flattenBlocks.contains {
            switch $0.information.content {
            case .text, .featuredRelations:
                return false
            default:
                return true
            }
        }

        if isExpectionTypesExists { return false }

        let textBlocks = flattenBlocks.filter { $0.information.content.isText }

        guard textBlocks.count < 3 else { return false }

        print("-_- textBlocks.count \(textBlocks.count)")

        switch textBlocks.count {
        case 0, 1:
            return true
        case 2:
            return textBlocks.last?.information.content.isEmpty ?? false
        default:
            return false
        }
    }
}

extension EditorAccessoryViewModel: ChangeTypeItemProvider {
    var typesPublisher: Published<[ChangeTypeAccessoryItemViewModel.Item]>.Publisher {
        $supportedTypes
    }
}
