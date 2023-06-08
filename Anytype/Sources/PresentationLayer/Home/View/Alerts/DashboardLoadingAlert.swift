import SwiftUI

struct DashboardLoadingAlert: View {
    
    let text: String
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(15)
            AnytypeText(text, style: .uxCalloutRegular, color: .Text.primary)
            Spacer.fixedHeight(13)
            ProgressBar(showAnimation: true)
            Spacer.fixedHeight(20)
        }
        .padding(.horizontal, 20)
        .background(Color.Background.primary)
        .cornerRadius(16)
    }
}

struct DashboardLoadingAlert_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
            DashboardLoadingAlert(text: "Removing objects")
        }
    }
}
