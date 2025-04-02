import SwiftUI
import ProtobufMessages

@MainActor
final class AutoWidgetAddedModifierModel: ObservableObject {
    
    @Published var toastBarData = ToastBarData.empty
    
    func startSubscription() async {
        for await events in await EventBunchSubscribtion.default.stream() {
            for event in events.middlewareEvents {
                switch event.value {
                case let .spaceAutoWidgetAdded(data):
                    AnytypeAnalytics.instance().logAddWidget(context: .auto, createType: .auto)
                    toastBarData = ToastBarData(
                        text: Loc.Widgets.autoAddedAlert(data.targetName),
                        showSnackBar: true,
                        messageType: .success
                    )
                default:
                    break
                }
            }
        }
    }
}
