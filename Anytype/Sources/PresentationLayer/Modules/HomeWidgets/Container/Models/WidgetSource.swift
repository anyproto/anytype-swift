import Foundation
import BlocksModels

enum WidgetSource: Equatable {
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
}

extension WidgetSource {
    var availableWidgetLayout: [BlockWidget.Layout] {
        switch self {
        case .object(let objectDetails):
            switch objectDetails.editorViewType {
            case .page:
               return [.tree, .link]
            case .set:
                return [.list, .link]
            case .favorites, .recent, .sets, .collections, .bin:
                return [.list, .tree]
            }
        case .library:
            return [.tree, .list]
        }
    }
}
