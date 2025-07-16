import Foundation
import Services

extension BlockContentType {
    var analyticsValue: String {
        switch self {
        case .smartblock:
            return "smartblock"
        case .text:
            return "text"
        case let .file(data):
            return data.contentType.rawValue
        case .divider:
            return "divider"
        case .bookmark:
            return "bookmark"
        case .link:
            return "link"
        case .layout:
            return "layout"
        case .featuredRelations:
            return "featuredRelations"
        case .relation:
            return "relationBlock"
        case .dataView:
            return "dataView"
        case .tableOfContents:
            return "tableOfContents"
        case .table:
            return "table"
        case .tableColumn:
            return "tableColumn"
        case .tableRow:
            return "tableRow"
        case .widget:
            return "widget"
        case .chat:
            return "chat"
        case .embed:
            return "latex"
        }
    }
    
    var styleAnalyticsValue: String {
        switch self {
        case let .smartblock(style):
            return String(describing: style)
        case let .text(style):
            return String(describing: style)
        case .file:
            return "Embed"
        case let .divider(style):
            return String(describing: style)
        case let .bookmark(style):
            return String(describing: style)
        case let .link(appearance):
            return String(describing: appearance)
        case let .layout(style):
            return String(describing: style)
        case .featuredRelations:
            return "featuredRelations"
        case let .relation(key):
            return "relationBlock \(key)"
        case .dataView:
            return "dataView"
        case .tableOfContents:
            return "tableOfContents"
        case .table:
            return "table"
        case .tableColumn:
            return "tableColumn"
        case .tableRow:
            return "tableRow"
        case let .widget(layout):
            return "Widget \(String(describing: layout))"
        case .chat:
            return "chat"
        case .embed:
            return "latex"
        }
    }
}
