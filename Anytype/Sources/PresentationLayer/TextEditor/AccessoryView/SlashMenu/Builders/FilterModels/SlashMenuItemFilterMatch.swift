import Foundation

enum SlashMenuItemFilterMatch: Comparable {
    case groupName
    case fullTitle
    case titleSubstring
    case titleSynonymsSubstring
    case aliaseSubstring
}
