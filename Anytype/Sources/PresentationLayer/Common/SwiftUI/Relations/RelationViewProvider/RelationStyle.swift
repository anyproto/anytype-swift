import SwiftUI

enum RelationStyle: Hashable {
    case regular(allowMultiLine: Bool)
    case featuredRelationBlock(FeaturedRelationSettings)
    case set
    case setCollection
    case filter(hasValues: Bool)
    case kanbanHeader
}

enum RelationPlaceholderType {
    case hint
    case empty
    case clear(withHint: Bool)
}

struct FeaturedRelationSettings: Hashable {
    let allowMultiLine: Bool
    let prefix: String?
    let showIcon: Bool
    let error: Bool
    
    init(allowMultiLine: Bool, prefix: String? = nil, showIcon: Bool = true, error: Bool = false) {
        self.allowMultiLine = allowMultiLine
        self.prefix = prefix
        self.showIcon = showIcon
        self.error = error
    }
}

extension RelationStyle {
    
    var font: AnytypeFont {
        switch self {
        case .regular, .filter:
            return .relation1Regular
        case .set, .featuredRelationBlock, .kanbanHeader:
            return .relation2Regular
        case .setCollection:
            return .relation3Regular
        }
    }

    var fontColor: Color {
        return Color(uiKitFontColor)
    }

    var uiKitFontColor: UIColor {
        switch self {
        case .regular, .set:
            return .Text.primary
        case .featuredRelationBlock, .filter, .setCollection, .kanbanHeader:
            return .Text.secondary
        }
    }
    
    var uiFontColorWithError: UIColor {
        switch self {
        case let .featuredRelationBlock(settings):
            return settings.error ? .Dark.red : uiKitFontColor
        default:
            return uiKitFontColor
        }
    }
    
    var fontColorWithError: Color {
        return Color(uiFontColorWithError)
    }
    
    var isError: Bool {
        switch self {
        case let .featuredRelationBlock(settings):
            return settings.error
        default:
            return false
        }
    }

    var allowMultiLine: Bool {
        switch self {
        case let .regular(value):
            return value
        case let .featuredRelationBlock(settings):
            return settings.allowMultiLine
        case .set, .filter, .setCollection, .kanbanHeader:
            return false
        }
    }
    
    var placeholderType: RelationPlaceholderType {
        switch self {
        case .regular, .featuredRelationBlock:
            return .hint
        case .set, .setCollection, .kanbanHeader:
            return .empty
        case let .filter(hasValues):
            return .clear(withHint: hasValues)
        }
    }
    
    var hintFont: AnytypeFont {
        switch self {
        case .regular, .set, .setCollection:
            return .calloutRegular
        case .featuredRelationBlock, .kanbanHeader:
            return .relation2Regular
        case .filter:
            return .relation1Regular
        }
    }
    
    
    var tagViewGuidlines: TagView.Guidlines {
        switch self {
        case .regular, .set:
            return TagView.Guidlines(textPadding: 6, cornerRadius: 5, tagHeight: Constants.size20.height)
        case .featuredRelationBlock, .filter, .kanbanHeader:
            return TagView.Guidlines(textPadding: 4, cornerRadius: 4, tagHeight: Constants.size18.height)
        case .setCollection:
            return TagView.Guidlines(textPadding: 4, cornerRadius: 3, tagHeight: Constants.size16.height)
        }
    }

    var objectRelationStyle: ObjectRelationView.ObjectRelationStyle {
        switch self {
        case .regular, .set, .filter:
            return ObjectRelationView.ObjectRelationStyle(hSpaсingList: 8, hSpaсingObject: 6, size: Constants.size20)
        case .featuredRelationBlock, .kanbanHeader:
            return ObjectRelationView.ObjectRelationStyle(hSpaсingList: 6, hSpaсingObject: 4, size: Constants.size18)
        case .setCollection:
            return ObjectRelationView.ObjectRelationStyle(hSpaсingList: 6, hSpaсingObject: 4, size: Constants.size16)
        }
    }
    
    var checkboxSize: CGSize {
        switch self {
        case .regular, .set, .filter:
            return Constants.size20
        case .featuredRelationBlock, .kanbanHeader:
            return Constants.size18
        case .setCollection:
            return Constants.size16
        }
    }
}

private extension RelationStyle {
    
    enum Constants {
        static let size20 = CGSize(width: 20, height: 20)
        static let size18 = CGSize(width: 18, height: 18)
        static let size16 = CGSize(width: 16, height: 16)
    }
    
}
