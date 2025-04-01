import SwiftUI

struct AutoWidgetAddedModifier: ViewModifier {
    
    @StateObject private var model = AutoWidgetAddedModifierModel()
    
    func body(content: Content) -> some View {
        content
            .task {
                await model.startSubscription()
            }
            .snackbar(toastBarData: $model.toastBarData)
    }
    
}

extension View {
    func handleAutoWidgetAdded() -> some View {
        modifier(AutoWidgetAddedModifier())
    }
}
