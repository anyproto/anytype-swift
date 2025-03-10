import Foundation

struct SlashMenuItem: Sendable {
    let type: SlashMenuItemType
    let children: [SlashAction]
}
