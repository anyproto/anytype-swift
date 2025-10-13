import Foundation
import Services
import AnytypeCore

enum WidgetSource: Equatable, Hashable, Sendable {
    case object(ObjectDetails)
    case library(AnytypeWidgetId)
}

extension WidgetSource {
    
    var sourceId: String {
        switch self {
        case .object(let objectDetails):
            return objectDetails.id
        case .library(let library):
            return library.rawValue
        }
    }
    
    var isLibrary: Bool {
        switch self {
        case .object:
            return false
        case .library:
            return true
        }
    }
}

extension WidgetSource {
    var availableWidgetLayout: [BlockWidget.Layout] {
        switch self {
        case .object(let objectDetails):
            return objectDetails.availableWidgetLayout
        case .library(let library):
            switch library {
            case .pinned, .recent, .recentOpen:
                return [.compactList, .list, .tree]
            }
        }
    }
}

extension ObjectDetails {
    var availableWidgetLayout: [BlockWidget.Layout] {
        switch editorViewType {
        case .page, .bookmark:
           return [.tree, .link]
        case .list, .type:
            return [.view, .compactList, .list, .link]
        case .date:
            return [.link]
        case .participant, .mediaFile,. chat:
            return []
        }
    }
}
