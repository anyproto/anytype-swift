import SwiftUI

struct FloaterAlertView: View {
    let title: String
    let description: String
    let leftButtonData: StandardButtonModel
    let rightButtonData: StandardButtonModel
    var showShadow: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(23)
            AnytypeText(title, style: .heading, color: .Text.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer.fixedHeight(11)
            AnytypeText(description, style: .uxCalloutRegular, color: .Text.primary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer.fixedHeight(8)
            buttons
        }
        .padding(.horizontal, 20)
        .background(Color.Background.secondary)
        .cornerRadius(16)
        .if(showShadow) {
            $0.shadow(color: Color.Shadow.primary, radius: 4)
        }
    }
    
    private var buttons: some View {
        HStack(spacing: 0) {
            StandardButton(model: leftButtonData)
            Spacer.fixedWidth(10)
            StandardButton(model: rightButtonData)
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
                leftButtonData: StandardButtonModel(text: "Cancel", style: .secondaryLarge, action: {}),
                rightButtonData: StandardButtonModel(text: "Delete", style: .warningLarge, action: {})
            )
        }
    }
}
