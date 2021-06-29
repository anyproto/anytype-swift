import BlocksModels
import Combine

class BlocksViewsBaseFileViewModel: BaseBlockViewModel {
    private var stateSubscription: AnyCancellable?
    private var fileURLSubscription: AnyCancellable?
    
    private var state: BlockFileState?
    private let fileContent: BlockFile
    
    init(
        _ block: BlockActiveRecordProtocol,
        content: BlockFile,
        delegate: BaseBlockDelegate?,
        router: EditorRouterProtocol,
        actionHandler: EditorActionHandlerProtocol
    ) {
        self.fileContent = content
        super.init(block, delegate: delegate, actionHandler: actionHandler, router: router)
        setupStateSubscription()
    }
    
    override var diffable: AnyHashable {
        return .init([
            "parent": super.diffable,
            "fileState": fileContent.state
        ])
    }
    
    override func didSelectRowInTableView() {
        if self.state == .uploading {
            return
        }
        self.handleReplace()
    }
    
    /// Handle replace contextual menu action
    func handleReplace() {
        
    }
    
    private func downloadFile() {
        switch fileContent.contentType {
        case .image:
            return
        case .video, .file:
            fileURLSubscription = URLResolver().obtainFileURLPublisher(fileId: fileContent.metadata.hash)
                .sinkWithDefaultCompletion("obtainFileURL") { [weak self] url in
                    guard let url = url else { return }
                    self?.router.saveFile(fileURL: url)
                }
            
        case .none:
            return
        }
    }
    
    private func setupStateSubscription() {
        stateSubscription = block.didChangeInformationPublisher().map { value -> BlockFile? in
            switch value.content {
            case let .file(value): return value
            default: return nil
            }
        }
        .safelyUnwrapOptionals().eraseToAnyPublisher()
        .sink { [weak self] file in
            self?.state = file.state
        }
    }
    
    func sendFile(at filePath: String) {
        actionHandler.upload(blockId: block.blockId, filePath: filePath)
    }
    
    // MARK: - ContextualMenuHandler
    override func makeContextualMenu() -> ContextualMenu {
        .init(title: "", children: [
            .init(action: .addBlockBelow),
            .init(action: .delete),
            .init(action: .duplicate),
            .init(action: .download),
            .init(action: .replace)
        ])
    }
    
    override func handle(contextualMenuAction: ContextualMenuAction) {
        switch contextualMenuAction {
        case .replace:
            self.handleReplace()
        case.download:
            self.downloadFile()
        default:
            break
        }
        super.handle(contextualMenuAction: contextualMenuAction)
    }
}
