import SwiftUI

struct AccountMigrationAlertView: View {
    
    @StateObject private var model: AccountMigrationAlertViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    init(data: AccountMigrationData) {
        _model = StateObject(wrappedValue: AccountMigrationAlertViewModel(data: data))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            DragIndicator()
            titleView
            CircleLoadingView()
                .frame(width: 32, height: 32)
            cancelButton
        }
        .padding(.horizontal, 20)
        .background(Color.Background.secondary)
        .task {
            await model.startMigration()
        }
        .onChange(of: model.dismiss) { _ in
            dismiss()
        }
    }
    
    private var titleView: some View {
        AnytypeText("Migration is in progress", style: .heading)
            .foregroundColor(.Text.primary)
            .multilineTextAlignment(.center)
    }
    
    private var cancelButton: some View {
        StandardButton(
            "Cancel migration",
            style: .secondaryMedium,
            action: { model.onCancelTap() }
        )
        .padding(.bottom, 16)
    }
}

