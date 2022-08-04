import SwiftUI

enum RelationStyle: Hashable {
    case regular(allowMultiLine: Bool)
    case featuredRelationBlock(allowMultiLine: Bool)
    case set
    case filter(hasValues: Bool)
}

enum RelationPlaceholderType {
    case hint
    case empty
    case clear(withHint: Bool)
}

extension RelationStyle {
    
    var font: AnytypeFont {
        switch self {
        case .regular, .filter:
            return .relation1Regular
        case .set:
            return .relation2Regular
        case .featuredRelationBlock:
            return .relation2Regular
        }
    }

    var fontColor: Color {
        switch self {
        case .regular, .set:
            return .textPrimary
        case .featuredRelationBlock, .filter:
            return .textSecondary
        }
    }

    var uiKitFontColor: UIColor {
        switch self {
        case .regular, .set:
            return .textPrimary
        case .featuredRelationBlock, .filter:
            return .textSecondary
        }
    }

    var allowMultiLine: Bool {
        switch self {
        case let .regular(value):
            return value
        case let .featuredRelationBlock(value):
            return value
        case .set, .filter:
            return false
        }
    }
    
    var placeholderType: RelationPlaceholderType {
        switch self {
        case .regular, .featuredRelationBlock:
            return .hint
        case .set:
            return .empty
        case let .filter(hasValues):
            return .clear(withHint: hasValues)
        }
    }
    
    var hintFont: AnytypeFont {
        switch self {
        case .regular, .set:
            return .callout
        case .featuredRelationBlock:
            return .relation2Regular
        case .filter:
            return .relation1Regular
        }
    }
    
    
    var tagViewGuidlines: TagView.Guidlines {
        switch self {
        case .regular, .set:
            return TagView.Guidlines(textPadding: 6, cornerRadius: 5, tagHeight: Constants.size20.height)
        case .featuredRelationBlock, .filter:
            return TagView.Guidlines(textPadding: 4, cornerRadius: 4, tagHeight: Constants.size18.height)
        }
    }

    var objectRelationStyle: ObjectRelationView.ObjectRelationStyle {
        switch self {
        case .regular, .set, .filter:
            return ObjectRelationView.ObjectRelationStyle(hSpaсingList: 8, hSpaсingObject: 6, size: Constants.size20)
        case .featuredRelationBlock:
            return ObjectRelationView.ObjectRelationStyle(hSpaсingList: 6, hSpaсingObject: 4, size: Constants.size18)
        }
    }
    
    var checkboxSize: CGSize {
        switch self {
        case .regular, .set, .filter:
            return Constants.size20
        case .featuredRelationBlock:
            return Constants.size18
        }
    }
    
    var objectIconImageUsecase: ObjectIconImageUsecase {
        switch self {
        case .regular, .set:
            return .mention(.body)
        case .featuredRelationBlock, .filter:
            return .featuredRelationsBlock
        }
    }
    
}

private extension RelationStyle {
    
    enum Constants {
        static let size20 = CGSize(width: 20, height: 20)
        static let size18 = CGSize(width: 18, height: 18)
    }
    
}
