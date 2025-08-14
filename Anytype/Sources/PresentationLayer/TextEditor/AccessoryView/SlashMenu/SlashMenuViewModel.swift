import Services
import UIKit
import AnytypeCore
import Combine

@MainActor
final class SlashMenuViewModel: ObservableObject {
    var onSlashAction: ((SlashAction) -> Void)?
    @Published private(set) var detailsMenuItems = [SlashMenuCellData]()
    
    private(set) var configuration: TextViewAccessoryConfiguration?
    private(set) var menuItems = [SlashMenuItem]()
    private(set) var popToRootSubject = PassthroughSubject<Void, Never>()

    private var filterStringMismatchLength = 0
    private let detailsMenuBuilder: SlashMenuCellDataBuilder
    private let itemsBuilder: SlashMenuItemsBuilder
    private let searchDataDebouncer = Debouncer()
    private var searchMenuItemsTask: Task<(), Never>?
    
    
    var resetSlashMenuHandler: (() -> Void)?
    
    init(detailsMenuBuilder: SlashMenuCellDataBuilder, itemsBuilder: SlashMenuItemsBuilder) {
        self.detailsMenuBuilder = detailsMenuBuilder
        self.itemsBuilder = itemsBuilder
    }
    
    func update(with spaceId: String, restrictions: some BlockRestrictions, relations: [Property]) {
        Task {
            menuItems = try await itemsBuilder.slashMenuItems(spaceId: spaceId, resrictions: restrictions, relations: relations)
        }
        
    }
    
    func handle(_ action: SlashAction) {
        onSlashAction?(action)
    }
    
    func restoreDefaultState() {
        popToRootSubject.send(())
    }
    
    func setFilterText(filterText: String) {
        popToRootSubject.send(())
        
        searchDataDebouncer.debounce(milliseconds: 1) { [weak self] in
            guard let self = self else { return }
            detailsMenuItems = detailsMenuBuilder.build(filter: filterText, menuItems: menuItems)
        }
    }
}
