enum SetKanbanBoardState: Equatable {
    case loading
    case ready
    case error(message: String)
}
