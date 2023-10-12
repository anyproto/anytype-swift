import SwiftUI
import AnytypeCore

struct PersonalizationView: View {
    @StateObject var model: PersonalizationViewModel

    var body: some View {
        VStack(spacing: 0) {
            if FeatureFlags.multiSpaceSettings {
                DragIndicator()
            }
            Spacer.fixedHeight(12)
            AnytypeText(Loc.personalization, style: .uxTitle1Semibold, color: .Text.primary)
            Spacer.fixedHeight(12)
            
            AnytypeRow(title: Loc.defaultObjectType, description: model.objectType, action: { model.onObjectTypeTap() })
            AnytypeRow(title: Loc.wallpaper, description: nil, action: { model.onWallpaperChangeTap() })
            Spacer.fixedHeight(20)
        }
        .background(Color.Background.secondary)
        .cornerRadius(16, corners: .top)
        .onAppear {
            AnytypeAnalytics.instance().logScreenSettingsPersonal()
        }
        .if(FeatureFlags.multiSpaceSettings, transform: {
            $0.fitPresentationDetents()
        })
    }
}

struct PersonalizationView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.System.blue
            PersonalizationView(model: PersonalizationViewModel(
                spaceId: "",
                objectTypeProvider: DI.preview.serviceLocator.objectTypeProvider(),
                output: nil
            ))
        }
    }
}
