import Foundation
import SwiftUI
import Combine
import BlocksModels

enum MarksPaneMainAttribute {
    case textColor(UIColor)
    case backgroundColor(UIColor)
    case fontStyle(BlockActionHandler.ActionType.TextAttributesType)
    case alignment(BlockInformationAlignment)
}
