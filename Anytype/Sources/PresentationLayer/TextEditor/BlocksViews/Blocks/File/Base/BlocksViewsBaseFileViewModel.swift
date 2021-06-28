import BlocksModels
import Combine

class BlocksViewsBaseFileViewModel: BaseBlockViewModel {
    private var subscription: AnyCancellable?
    private var subscriptions: Set<AnyCancellable> = []
    
    private var fileContentPublisher: AnyPublisher<BlockFile, Never> = .empty()
    
    @Published var state: BlockFileState? { willSet { self.objectWillChange.send() } }
    
    init(
        _ block: BlockActiveRecordModelProtocol,
        delegate: BaseBlockDelegate?,
        router: EditorRouterProtocol?,
        actionHandler: NewBlockActionHandler?
    ) {
        super.init(block, delegate: delegate, actionHandler: actionHandler, router: router)
        setupSubscribers()
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
    
    override func makeContextualMenu() -> BlocksViews.ContextualMenu {
        .init(title: "", children: [
            .create(action: .general(.addBlockBelow)),
            .create(action: .general(.delete)),
            .create(action: .general(.duplicate)),
            .create(action: .specific(.download)),
            .create(action: .specific(.replace))
        ])
    }
    
    override func handle(contextualMenuAction: BlocksViews.ContextualMenu.MenuAction.Action) {
        switch contextualMenuAction {
        case let .specific(specificAction):
            switch specificAction {
            case .replace:
                self.handleReplace()
            case.download:
                self.downloadFile()
            default:
                break
            }
        default:
            break
        }
        super.handle(contextualMenuAction: contextualMenuAction)
    }
    
    /// Handle replace contextual menu action
    func handleReplace() {
        
    }
    
    func configureMediaPickerViewModel(_ pickerViewModel: MediaPicker.ViewModel) {
        pickerViewModel.onResultInformationObtain = { [weak self] resultInformation in
            guard let resultInformation = resultInformation else { return }
            
            self?.sendFile(at: resultInformation.filePath)
        }
    }
    
    /// Add observer to file picker
    ///
    /// - Parameters:
    ///   - pickerViewModel: Model with information about picked file
    func configureListening(_ pickerViewModel: BaseFilePickerViewModel) {
        pickerViewModel.$resultInformation.safelyUnwrapOptionals().sink { [weak self] (value) in
            self?.sendFile(at: value.filePath)
        }.store(in: &self.subscriptions)
    }
    
    private func downloadFile() {
        guard case let .file(file) = block.content else { return }
        switch file.contentType {
        case .image:
            return
        case .video, .file:
            URLResolver().obtainFileURLPublisher(fileId: file.metadata.hash)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] url in
                        guard let url = url else { return }
                        self?.router?.saveFile(fileURL: url)
                    }
                )
                .store(in: &self.subscriptions)
            
        case .none:
            return
        }
    }
    
    private func setupSubscribers() {
        let fileContentPublisher = block.didChangeInformationPublisher().map({ value -> BlockFile? in
            switch value.content {
            case let .file(value): return value
            default: return nil
            }
        }).safelyUnwrapOptionals().eraseToAnyPublisher()
        /// Should we store it (?)
        self.fileContentPublisher = fileContentPublisher
        
        self.subscription = self.fileContentPublisher.sink { [weak self] file in
            self?.state = file.state
        }
    }
    
    private func sendFile(at filePath: String) {
        actionHandler?.handleAction(.upload(filePath: filePath), model: block.blockModel)
    }
}
