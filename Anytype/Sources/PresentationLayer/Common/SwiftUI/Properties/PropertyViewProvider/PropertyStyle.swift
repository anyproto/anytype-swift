import SwiftUI

enum PropertyStyle: Hashable {
    case regular(allowMultiLine: Bool)
    case featuredBlock(FeaturedPropertySettings)
    case set
    case setCollection
    case filter(hasValues: Bool)
    case kanbanHeader
}

enum PropertyPlaceholderType {
    case hint
    case empty
    case clear(withHint: Bool)
}

struct FeaturedPropertySettings: Hashable {
    let allowMultiLine: Bool
    let prefix: String?
    let showIcon: Bool
    let error: Bool
    let links: Property.Object.Links?
    
    init(allowMultiLine: Bool, prefix: String? = nil, showIcon: Bool = true, error: Bool = false, links: Property.Object.Links? = nil) {
        self.allowMultiLine = allowMultiLine
        self.prefix = prefix
        self.showIcon = showIcon
        self.error = error
        self.links = links
    }
}

extension PropertyStyle {
    
    var font: AnytypeFont {
        switch self {
        case .regular, .filter:
            return .relation1Regular
        case .set, .featuredBlock, .kanbanHeader:
            return .relation2Regular
        case .setCollection:
            return .relation3Regular
        }
    }

    var fontColor: Color {
        switch self {
        case .regular, .set:
            return .Text.primary
        case .featuredBlock, .filter, .setCollection, .kanbanHeader:
            return .Text.secondary
        }
    }
    
    var fontColorWithError: Color {
        switch self {
        case let .featuredBlock(settings):
            return settings.error ? .Dark.red : fontColor
        default:
            return fontColor
        }
    }
    
    var isError: Bool {
        switch self {
        case let .featuredBlock(settings):
            return settings.error
        default:
            return false
        }
    }

    var allowMultiLine: Bool {
        switch self {
        case let .regular(value):
            return value
        case let .featuredBlock(settings):
            return settings.allowMultiLine
        case .set, .filter, .setCollection, .kanbanHeader:
            return false
        }
    }
    
    var placeholderType: PropertyPlaceholderType {
        switch self {
        case .regular, .featuredBlock:
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
        case .featuredBlock, .kanbanHeader:
            return .relation2Regular
        case .filter:
            return .relation1Regular
        }
    }
    
    var hintColor: Color {
        Color.Text.tertiary
    }
    
    var tagViewGuidlines: TagView.Guidlines {
        switch self {
        case .regular, .set:
            return TagView.Guidlines(textPadding: 6, cornerRadius: 5, tagHeight: Constants.size20.height)
        case .featuredBlock, .filter, .kanbanHeader:
            return TagView.Guidlines(textPadding: 4, cornerRadius: 4, tagHeight: Constants.size18.height)
        case .setCollection:
            return TagView.Guidlines(textPadding: 4, cornerRadius: 3, tagHeight: Constants.size16.height)
        }
    }

    var objectPropertyStyle: ObjectPropertyView.ObjectPropertyStyle {
        switch self {
        case .regular, .set, .filter:
            return ObjectPropertyView.ObjectPropertyStyle(hSpaсingList: 8, hSpaсingObject: 6, size: Constants.size20)
        case .featuredBlock, .kanbanHeader:
            return ObjectPropertyView.ObjectPropertyStyle(hSpaсingList: 6, hSpaсingObject: 4, size: Constants.size18)
        case .setCollection:
            return ObjectPropertyView.ObjectPropertyStyle(hSpaсingList: 6, hSpaсingObject: 4, size: Constants.size16)
        }
    }
    
    var checkboxSize: CGSize {
        switch self {
        case .regular, .set, .filter:
            return Constants.size20
        case .featuredBlock, .kanbanHeader:
            return Constants.size18
        case .setCollection:
            return Constants.size16
        }
    }
    
    var links: Property.Object.Links? {
        switch self {
        case .regular, .set, .filter, .setCollection, .kanbanHeader:
            return nil
        case .featuredBlock(let settings):
            return settings.links
        }
    }
}

private extension PropertyStyle {
    
    enum Constants {
        static let size20 = CGSize(width: 20, height: 20)
        static let size18 = CGSize(width: 18, height: 18)
        static let size16 = CGSize(width: 16, height: 16)
    }
    
}
