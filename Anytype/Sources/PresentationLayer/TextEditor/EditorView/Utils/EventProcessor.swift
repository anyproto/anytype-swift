class EventProcessor {
    let document: BaseDocumentProtocol
    let modelsHolder: SharedBlockViewModelsHolder
    
    init(
        document: BaseDocumentProtocol,
        modelsHolder: SharedBlockViewModelsHolder
    ) {
        self.document = document
        self.modelsHolder = modelsHolder
    }
    
    func process(events: PackOfEvents) {
        events.localEvents.forEach { event in
            switch event {
            case let .setFocus(blockId, position):
                if let blockViewModel = modelsHolder.models.first(where: { $0.blockId == blockId }) as? TextBlockViewModel {
                    blockViewModel.set(focus: position)
                }
            default: return
            }
        }
        document.handle(events: events)
    }
}
