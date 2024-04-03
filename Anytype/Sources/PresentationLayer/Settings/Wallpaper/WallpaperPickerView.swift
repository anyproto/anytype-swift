import SwiftUI
import AnytypeCore

struct WallpaperPickerView: View {
    @StateObject private var model: WallpaperPickerViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(spaceId: String) {
        self._model = StateObject(wrappedValue: WallpaperPickerViewModel(spaceId: spaceId))
    }
    
    var body: some View {
        VStack(alignment: .center) {
            DragIndicator()
            Spacer.fixedHeight(12)
            AnytypeText(Loc.changeWallpaper, style: .uxTitle1Semibold, color: .Text.primary)
            Spacer.fixedHeight(12)
            WallpaperColorsGridView() { background in
                AnytypeAnalytics.instance().logSettingsWallpaperSet()
                model.wallpaper = background
                dismiss()
            }
        }
        .background(Color.Background.secondary)
        .onAppear {
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.wallpaperSettingsShow)
        }
    }
}
