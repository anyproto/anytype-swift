import SwiftUI

struct FloaterAlertView: View {
    let title: String
    let description: String
    let cancelButtonData: StandardButtonData
    let destructiveButtonData: StandardButtonData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(23)
            AnytypeText(title, style: .heading, color: .textPrimary)
            Spacer.fixedHeight(11)
            AnytypeText(description, style: .uxCalloutRegular, color: .textPrimary)
            Spacer.fixedHeight(8)
            buttons
        }
        .padding(.horizontal, 20)
        .background(Color.background)
        .cornerRadius(16)
    }
    
    private var buttons: some View {
        HStack(spacing: 0) {
            StandardButton(data: cancelButtonData)
            Spacer.fixedWidth(10)
            StandardButton(data: destructiveButtonData)
        }
        .padding(.vertical, 10)
    }
}

struct FloaterAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.pureBlue
            FloaterAlertView(
                title: "Are you sure you want to delete 3 objects?",
                description: "These objects will be deleted irrevocably. You can’t undo this action.",
                cancelButtonData: StandardButtonData(text: "Cancel", style: .secondary, action: {}),
                destructiveButtonData: StandardButtonData(text: "Delete", style: .destructive, action: {})
            )
        }
    }
}
