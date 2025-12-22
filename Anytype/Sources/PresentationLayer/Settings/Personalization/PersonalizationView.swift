import SwiftUI
import AnytypeCore

struct PersonalizationView: View {
    @StateObject private var model: PersonalizationViewModel

    init(spaceId: String, output: (any PersonalizationModuleOutput)?) {
        self._model = StateObject(wrappedValue: PersonalizationViewModel(spaceId: spaceId, output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(12)
            AnytypeText(Loc.personalization, style: .uxTitle1Semibold)
                .foregroundStyle(Color.Text.primary)
            Spacer.fixedHeight(12)
            
            AnytypeRow(title: Loc.defaultObjectType, description: model.objectType, action: { model.onObjectTypeTap() })
            AnytypeRow(title: Loc.wallpaper, description: nil, action: { model.onWallpaperChangeTap() })
            Spacer.fixedHeight(20)
        }
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, topTrailingRadius: 16))
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
            Color.Pure.blue
            PersonalizationView(spaceId: "", output: nil)
        }
    }
}
