import SwiftUI
import AnytypeCore

struct PersonalizationView: View {
    @StateObject var model: PersonalizationViewModel

    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(12)
            AnytypeText(Loc.personalization, style: .uxTitle1Semibold, color: .Text.primary)
            Spacer.fixedHeight(12)
            
            AnytypeRow(title: Loc.defaultObjectType, description: model.objectType, action: { model.onObjectTypeTap() })
            AnytypeRow(title: Loc.wallpaper, description: nil, action: { model.onWallpaperChangeTap() })
            Spacer.fixedHeight(20)
        }
        .cornerRadius(16, corners: .top)
        .onAppear {
            AnytypeAnalytics.instance().logScreenSettingsPersonal()
        }
        .fitPresentationDetents()
        .background(Color.Background.secondary)
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
