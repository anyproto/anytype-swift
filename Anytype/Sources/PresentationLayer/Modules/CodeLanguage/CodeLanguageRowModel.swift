import Foundation

struct CodeLanguageRowModel: Identifiable {
    let id: String
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
}
