import SwiftUI
import AnytypeCore

struct PersonalizationView: View {
    @ObservedObject var model: PersonalizationViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(12)
            AnytypeText(Loc.personalization, style: .uxTitle1Semibold, color: .Text.primary)
            Spacer.fixedHeight(12)
            
            defaultType
            Spacer.fixedHeight(20)
        }
        .background(Color.Background.secondary)
        .cornerRadius(16, corners: .top)
        
        .onAppear {
            AnytypeAnalytics.instance().logScreenSettingsPersonal()
        }
    }

    private var defaultType: some View {
        Button(action: { model.onObjectTypeTap() }) {
            HStack(spacing: 0) {
                AnytypeText(Loc.defaultObjectType, style: .uxBodyRegular, color: .Text.primary)
                Spacer()
                AnytypeText(model.objectType, style: .uxBodyRegular, color: .Text.secondary)
                Spacer.fixedWidth(10)
                Image(asset: .arrowForward).foregroundColor(.Text.tertiary)
            }
            .padding(.vertical, 14)
            .divider()
            .padding(.horizontal, 20)
        }
    }
}

struct PersonalizationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.System.blue
            PersonalizationView(model: PersonalizationViewModel(
                objectTypeProvider: DI.preview.serviceLocator.objectTypeProvider(),
                output: nil
            ))
        }
    }
}
