import Foundation
import SwiftUI

struct ForceDeleteAlert: View {
    
    @StateObject private var model: ForceDeleteAlertModel
    @Environment(\.dismiss) private var dismiss
    
    init(data: ForceDeleteAlertData) {
        self._model = StateObject(wrappedValue: ForceDeleteAlertModel(data: data))
    }
    
    var body: some View {
        BottomAlertView(
            title: Loc.FilesList.ForceDelete.title,
            message: Loc.WidgetObjectList.ForceDelete.message,
            buttons: {
                BottomAlertButton(text: Loc.cancel, style: .secondary, action: {
                    dismiss()
                })
                BottomAlertButton(text: Loc.delete, style: .warning, action: {
                    try await model.onDelete()
                    dismiss()
                })
            }
        )
        .onAppear {
            model.onAppear()
        }
    }
}
