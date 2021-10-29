import Foundation
import AnytypeCore

public enum ObjectDetailsItem {
    case name(String)
    case iconEmoji(String)
    case iconImageHash(Hash?)
    case coverId(String)
    case coverType(CoverType)
    case type(String)
    case isDraft(Bool)
}
