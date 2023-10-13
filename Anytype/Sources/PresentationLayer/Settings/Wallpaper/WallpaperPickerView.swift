import SwiftUI
import AnytypeCore

struct WallpaperPickerView: View {
    @StateObject var model: WallpaperPickerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .center) {
            DragIndicator()
            Spacer.fixedHeight(12)
            AnytypeText(Loc.changeWallpaper, style: .uxTitle1Semibold, color: .Text.primary)
            Spacer.fixedHeight(12)
            WallpaperColorsGridView() { background in
                AnytypeAnalytics.instance().logSettingsWallpaperSet()
                model.wallpaper = background
                presentationMode.wrappedValue.dismiss()
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
        WallpaperPickerView(model: WallpaperPickerViewModel(spaceId: ""))
    }
}
