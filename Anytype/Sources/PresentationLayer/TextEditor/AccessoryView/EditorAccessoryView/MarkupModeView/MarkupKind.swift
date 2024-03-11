import Foundation
import Services

extension MarkupAccessoryViewModel {
    enum FontStyle: CaseIterable {
        case bold
        case italic
        case strikethrough
        case underscored
        case keyboard
    }

    enum MarkupKind: CaseIterable {
        case fontStyle(FontStyle)
        case link
        case color

        static var allCases: [MarkupAccessoryViewModel.MarkupKind] {
            var allMarkup = FontStyle.allCases.map {
                MarkupKind.fontStyle($0)
            }
            allMarkup += [.link, .color]

            return allMarkup
        }
    }
}

extension MarkupAccessoryViewModel.MarkupKind {

    var iconAsset: ImageAsset {
        switch self {
        case .fontStyle(.bold):
            return .TextStyles.bold
        case .fontStyle(.italic):
            return .TextStyles.italic
        case .fontStyle(.strikethrough):
            return .TextStyles.strikethrough
        case .fontStyle(.underscored):
            return .TextStyles.underline
        case .fontStyle(.keyboard):
            return .TextStyles.code
        case .link:
            return .TextStyles.embed
        case .color:
            return .X32.color
        }
    }

    func hasMarkup(for text: NSAttributedString, range: NSRange) -> Bool {
        switch self {
        case let .fontStyle(fontStyle):
            return text.hasMarkup(fontStyle.markupType, range: range)
        case .link:
            return text.linkState(range: range).isNotNil || text.linkToObjectState(range: range).isNotNil
        case .color:
            return true
        }
    }
}

extension MarkupAccessoryViewModel.FontStyle {
    var markupType: MarkupType {
        switch self {
        case .bold:
            return .bold
        case .italic:
            return .italic
        case .strikethrough:
            return .strikethrough
        case .underscored:
            return .underscored
        case .keyboard:
            return .keyboard
        }
    }
}
