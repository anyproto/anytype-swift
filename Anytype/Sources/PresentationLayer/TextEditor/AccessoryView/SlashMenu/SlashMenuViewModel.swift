import Services
import UIKit
import AnytypeCore
import Combine

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
    
    func update(with restrictions: BlockRestrictions, relations: [Relation]) {
        Task {
            menuItems = try await itemsBuilder.slashMenuItems(spaceId: "", resrictions: restrictions, relations: relations)
        }
        
    }
    
    func handle(_ action: SlashAction) {
        onSlashAction?(action)
    }
    
    func didShowMenuView(from textView: UITextView) {
//        self.textView = textView
//        selectedRange = NSRange(
//            location: textView.selectedRange.location - 1,
//            length: 0
//        )
    }
    
    func restoreDefaultState() {
        popToRootSubject.send(())
    }
    
    func setFilterText(filterText: String) {
//        guard cachedFilterText != filterText else { return }
        
        popToRootSubject.send(())
        
        searchDataDebouncer.debounce(milliseconds: 1) { [weak self] in
            guard let self = self else { return }
            detailsMenuItems = detailsMenuBuilder.build(filter: filterText, menuItems: menuItems)
        }
        
        
        
//        if !detailsMenuItems.isEmpty {
//            filterStringMismatchLength = 0
//        } else {
//            filterStringMismatchLength += filterText.count - cachedFilterText.count
//        }
        
//        cachedFilterText = filterText
    }
    
    private func removeSlashMenuText() {
        // After we select any action from actions menu we must delete /symbol
        // and all text which was typed after /
        //
        // We create text range from two text positions and replace text in
        // this range with empty string
        
//        configuration
//        guard let selectedRange = selectedRange,
//              let textView = textView,
//              let info = info else {
//            return
//        }
//        let mutableText = textView.attributedText.mutable
//
//        let range = NSRange(
//            location: selectedRange.location,
//            length: textView.selectedRange.location - selectedRange.location
//        )
//
//        mutableText.replaceCharacters(in: range, with: "")
//        handler.changeText(mutableText, info: info)
//        textView.attributedText = mutableText
//        textView.selectedRange = NSRange(location: selectedRange.location, length: 0)
    }
}
