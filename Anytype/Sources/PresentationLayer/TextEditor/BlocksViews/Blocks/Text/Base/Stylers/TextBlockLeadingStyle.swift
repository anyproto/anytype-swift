import AnytypeCore

struct CalloutIconViewModel {
    let onTap: () -> Void
    let iconImageModel: ObjectIconImageModel
}

enum TextBlockLeadingStyle {
    struct TitleModel {
        let isCheckable: Bool
        let checked: Bool
        let toggleAction: () -> Void
    }

    struct ToggleModel {
        let isToggled: Bool
        let toggleAction: () -> Void
    }

    struct CheckboxModel {
        let isChecked: Bool
        let toggleAction: () -> Void
    }

    case title(TitleModel)
    case toggle(ToggleModel)
    case checkbox(CheckboxModel)
    case numbered(Int)
    case bulleted
    case quote
    case body
    case callout(CalloutIconViewModel)

    init(with configuration: TextBlockContentConfiguration) {
        switch configuration.content.contentType {
        case .title:
            self = .title(
                .init(
                    isCheckable: configuration.isCheckable,
                    checked: configuration.isChecked,
                    toggleAction: configuration.actions.toggleCheckBox
                )
            )
        case .toggle:
            self = .toggle(
                .init(
                    isToggled: configuration.isToggled,
                    toggleAction: configuration.actions.toggleDropDown
                )
            )
        case .bulleted:
            self = .bulleted
        case .checkbox:
            self = .checkbox(
                .init(
                    isChecked: configuration.isChecked,
                    toggleAction: configuration.actions.toggleCheckBox
                )
            )
        case .numbered:
            self = .numbered(configuration.content.number)
        case .callout:
            let objectIconImage: ObjectIconImage
            if let emoji = Emoji(configuration.content.iconEmoji) {
                objectIconImage = .icon(.emoji(emoji))
            } else {
                objectIconImage = .icon(.basic(configuration.content.iconImage))
            }

            self = .callout(
                .init(
                    onTap: {
                        configuration.actions.tapOnCalloutIcon()
                    }, iconImageModel: .init(iconImage: objectIconImage, usecase: .editorCalloutBlock)
                )
            )
        case .header, .header2, .header3, .header4, .code, .description, .text, .quote:
            self = .body
        }
    }
}
