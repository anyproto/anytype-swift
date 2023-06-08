import Foundation
import Combine
import SwiftUI
import AudioToolbox

struct AboutView: View {
    
    @ObservedObject var model: AboutViewModel
    
    var body: some View {
        contentView
            .onAppear {
                AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.aboutSettingsShow)
            }
    }
    
    var contentView: some View {
        VStack(alignment: .center, spacing: 0) {
            
            Spacer.fixedHeight(12)
            title
            Spacer.fixedHeight(12)
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(model.rows) { row in
                    rowView(model: row)
                }
            }
            .padding(.horizontal, 20)
            Spacer.fixedHeight(20)
        }
        .background(Color.Background.secondary)
        .cornerRadius(12, corners: .top)
        .snackbar(toastBarData: $model.snackBarData)
    }
    
    func rowView(model: AboutRowModel) -> some View {
        Button {
            model.onTap()
        } label: {
            HStack(alignment: .top) {
                AnytypeText(model.title, style: .uxBodyRegular, color: .Text.secondary)
                Spacer.fixedWidth(50)
                Spacer()
                AnytypeText(model.value, style: .uxBodyRegular, color: .Text.primary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 14)
            .divider()
        }
    }
    
    @State private var titleTapCount = 0
    var title: some View {
        AnytypeText(Loc.about, style: .uxTitle1Semibold, color: .Text.primary)
            .onTapGesture {
                titleTapCount += 1
                if titleTapCount == 10 {
                    titleTapCount = 0
                    AudioServicesPlaySystemSound(1109)
                    model.onDebugMenuTap()
                }
            }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(model: AboutViewModel(
            middlewareConfigurationProvider: DI.preview.serviceLocator.middlewareConfigurationProvider(),
            accountManager: DI.preview.serviceLocator.accountManager(),
            output: nil
        ))
    }
}
