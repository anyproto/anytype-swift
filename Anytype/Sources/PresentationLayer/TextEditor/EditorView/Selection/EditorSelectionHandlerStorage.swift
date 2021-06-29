import BlocksModels

struct EditorSelectionHandlerStorage {
    typealias Id = BlockId
    typealias Ids = Set<Id>
    /// Selected ids that user has selected.
    private var selectedIds: Ids = .init()
    
    /// Flag that determines if user initiates selection mode.
    private var isSelectionEnabled: Bool = false {
        didSet {
            if !self.isSelectionEnabled {
                self.clear()
            }
        }
    }
    
    // MARK: Selection
    func selectionEnabled() -> Bool { self.isSelectionEnabled }
    mutating func toggleSelectionEnabled() { self.isSelectionEnabled.toggle() }
    mutating func startSelection() { self.isSelectionEnabled = true }
    mutating func stopSelection() { self.isSelectionEnabled = false }
    
    // MARK: Ids
    func isEmpty() -> Bool { self.selectedIds.isEmpty }
    func count() -> Int { self.selectedIds.count }
    func listSelectedIds() -> [Id] { .init(self.selectedIds) }
    func contains(id: Id) -> Bool { self.selectedIds.contains(id) }
    mutating func set(ids: Ids) { self.selectedIds = ids }
    mutating func clear() { self.selectedIds = .init() }
    mutating func toggle(id: Id) { self.selectedIds.contains(id) ? self.remove(id: id) : self.add(id: id) }
    mutating func add(id: Id) { self.selectedIds.insert(id) }
    mutating func remove(id: Id) { self.selectedIds.remove(id) }
    
    mutating func add(ids: Set<Id>) { self.selectedIds = self.selectedIds.union(ids) }
    mutating func remove(ids: Set<Id>) { self.selectedIds = self.selectedIds.subtracting(ids) }
}
