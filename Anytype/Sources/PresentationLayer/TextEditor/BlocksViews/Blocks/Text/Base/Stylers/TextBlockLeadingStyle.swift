import AnytypeCore

struct CalloutIconViewModel {
    let onTap: () -> Void
    let icomImage: Icon
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
            let Icon: Icon

            if configuration.content.iconImage.isNotEmpty {
                Icon = .object(.basic(configuration.content.iconImage))
            } else {
                Icon = .object(.emoji(Emoji(configuration.content.iconEmoji) ?? .lamp))
            }

            self = .callout(
                .init(
                    onTap: {
                        configuration.actions.tapOnCalloutIcon()
                    },
                    icomImage: Icon
                )
            )
        case .header, .header2, .header3, .header4, .code, .description, .text, .quote:
            self = .body
        }
    }
}
