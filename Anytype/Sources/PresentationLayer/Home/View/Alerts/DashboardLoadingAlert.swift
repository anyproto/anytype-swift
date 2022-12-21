import SwiftUI

struct DashboardLoadingAlert: View {
    @EnvironmentObject private var model: HomeViewModel
    
    let text: String
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(15)
            AnytypeText(text, style: .uxCalloutRegular, color: .textPrimary)
            Spacer.fixedHeight(13)
            ProgressBar(showAnimation: model.loadingAlertData.showAlert)
            Spacer.fixedHeight(20)
        }
        .padding(.horizontal, 20)
        .background(Color.BackgroundNew.primary)
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
