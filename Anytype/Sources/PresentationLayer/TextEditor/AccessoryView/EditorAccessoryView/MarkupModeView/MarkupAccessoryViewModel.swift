import Services
import SwiftUI
import Combine
import AnytypeCore

struct MarkupItem: Identifiable, Equatable {
    let id = UUID()
    let markupItem: MarkupAccessoryViewModel.MarkupKind

    static func == (lhs: MarkupItem, rhs: MarkupItem) -> Bool {
        lhs.id == rhs.id
    }

    static var allItems: [MarkupItem] {
        MarkupAccessoryViewModel.MarkupKind.allCases.map {
            MarkupItem(markupItem: $0)
        }
    }
}

@MainActor
final class MarkupAccessoryViewModel: ObservableObject {
    let markupItems: [MarkupItem] = MarkupItem.allItems

    private(set) var restrictions: (any BlockRestrictions)?
    
    var onMarkupTap: RoutingAction<MarkupKind>?
    var onColorSelection: RoutingAction<ColorView.ColorItem>?
    
    private var configuration: TextViewAccessoryConfiguration?

    @Published private(set) var range: NSRange = .zero
    @Published var showColorView: Bool = false

    var colorButtonFrame: CGRect?

    private var cancellables = [AnyCancellable]()

    init() {}

    func update(_ configuration: TextViewAccessoryConfiguration) {
        self.configuration = configuration
        restrictions = BlockRestrictionsBuilder.build(contentType: configuration.contentType)

        updateRange(range: range)
    }

    func updateRange(range: NSRange) {
        self.range = range
        
        objectWillChange.send()
    }

    func action(_ markup: MarkupKind) {
        onMarkupTap?(markup)
        objectWillChange.send()
    }

    func iconColor(for markup: MarkupKind) -> Color {
        let state = attributeState(for: markup)

        switch state {
        case .disabled:
            return .Control.tertiary
        case .applied:
            return .Control.primary
        case .notApplied:
            return .Control.secondary
        }
    }

    func handleSelectedColorItem(_ colorItem: ColorView.ColorItem) {
        onColorSelection?(colorItem)
    }
    
    func foregroundColorState() -> UIColor {
        guard let configuration else { return UIColor.Dark.default }
        return configuration.textView.attributedText.colorState(range: configuration.textView.selectedRange) ?? UIColor.Dark.default
    }
    
    func backgroundColorState() -> UIColor {
        guard let configuration else { return UIColor.VeryLight.default }
        return configuration.textView.attributedText.backgroundColor(range: configuration.textView.selectedRange) ?? UIColor.VeryLight.default
    }

    private func attributeState(for markup: MarkupKind) -> AttributeState {
        guard let restrictions = restrictions else { return .disabled }

        switch markup {
        case .fontStyle(let fontStyle):
            guard restrictions.isMarkupAvailable(fontStyle.markupType) else { return .disabled }
        case .link, .color:
            guard restrictions.canApplyOtherMarkup else { return .disabled }
        }

        guard let configuration else { return .disabled }
        if markup.hasMarkup(for: configuration.textView.attributedText, range: range) {
            return .applied
        }
        return .notApplied
    }
}
