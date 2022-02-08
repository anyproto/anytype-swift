import SwiftUI

struct FloaterAlertView: View {
    let title: String
    let description: String
    let leftButtonData: StandardButtonData
    let rightButtonData: StandardButtonData
    
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
        .background(Color.backgroundSecondary)
        .cornerRadius(16)
        .shadow(color: Color.shadowPrimary, radius: 4)
    }
    
    private var buttons: some View {
        HStack(spacing: 0) {
            StandardButton(data: leftButtonData)
            Spacer.fixedWidth(10)
            StandardButton(data: rightButtonData)
        }
        .padding(.vertical, 10)
    }
}

struct FloaterAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.System.blue
            FloaterAlertView(
                title: "Are you sure you want to delete 3 objects?",
                description: "These objects will be deleted irrevocably. You can’t undo this action.",
                leftButtonData: StandardButtonData(text: "Cancel", style: .secondary, action: {}),
                rightButtonData: StandardButtonData(text: "Delete", style: .destructive, action: {})
            )
        }
    }
}
