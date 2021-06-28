import BlocksModels
import Combine

class BlocksViewsBaseFileViewModel: BaseBlockViewModel {
    private var stateSubscription: AnyCancellable?
    private var fileURLSubscription: AnyCancellable?
    
    @Published var state: BlockFileState? { willSet { self.objectWillChange.send() } }
    
    init(
        _ block: BlockActiveRecordModelProtocol,
        delegate: BaseBlockDelegate?,
        router: EditorRouterProtocol?,
        actionHandler: NewBlockActionHandler?
    ) {
        super.init(block, delegate: delegate, actionHandler: actionHandler, router: router)
        setupStateSubscription()
    }
    
    override var diffable: AnyHashable {
        let diffable = super.diffable
        if case let .file(value) = block.content {
            let newDiffable: [String: AnyHashable] = [
                "parent": diffable,
                "fileState": value.state
            ]
            return .init(newDiffable)
        }
        return diffable
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
        guard case let .file(file) = block.content else { return }
        switch file.contentType {
        case .image:
            return
        case .video, .file:
            fileURLSubscription = URLResolver().obtainFileURLPublisher(fileId: file.metadata.hash)
                .sinkWithDefaultCompletion("obtainFileURL") { [weak self] url in
                    guard let url = url else { return }
                    self?.router?.saveFile(fileURL: url)
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
        actionHandler?.handleAction(.upload(filePath: filePath), model: block.blockModel)
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
