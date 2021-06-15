/// This is Event wrapper enumeration.
///
/// Consider following scenario.
///
/// You have several delegates that sends events.
///
/// `ADelegate` sends `AEvent` and `BDelegate` sends `BEvent`
///
/// Let us wrap them into one action.
///
/// enum Action {
///  .aAction(AEvent)
///  .bAction(BEvent)
/// }
///
/// This `UserInteraction` enumeration wrap `TextView.UserAction` and `ButtonView.UserAction` together
enum TextBlockUserInteraction {
    case textView(CustomTextView.UserAction)
    case buttonView(ButtonView.UserAction)
}

extension TextBlockUserInteraction {
    enum ButtonView {
        enum UserAction {
            enum Toggle {
                case toggled(Bool)
                case insertFirst(Bool)
            }
            case toggle(Toggle)
            case checkbox(Bool)
        }
    }
}

