import SwiftUI
import AnytypeCore

struct WallpaperPickerView: View {
    @EnvironmentObject var model: SettingsViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            DragIndicator()
            Spacer.fixedHeight(12)
            AnytypeText(Loc.changeWallpaper, style: .uxTitle1Semibold, color: .Text.primary)
            Spacer.fixedHeight(12)
            WallpaperColorsGridView() { background in
                model.wallpaper = background
                model.wallpaperPicker = false
            }
        }
        .background(Color.Background.secondary)
        .onAppear {
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.wallpaperSettingsShow)
        }
    }
}

struct WallpaperPickerView_Previews: PreviewProvider {
    static var previews: some View {
        WallpaperPickerView()
    }
}
