import Foundation

enum SlashMenuItemFilterMatch: Comparable {
    case singleActionFullTitle
    case singleActionTitleSubstring
    case groupName
    case fullTitle
    case titleSubstring
    case titleSynonymsSubstring
    case aliaseSubstring
}
