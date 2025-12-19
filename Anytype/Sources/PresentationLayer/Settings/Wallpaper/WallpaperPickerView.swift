import SwiftUI
import AnytypeCore

struct WallpaperPickerView: View {
    @State private var model: WallpaperPickerViewModel
    @Environment(\.dismiss) private var dismiss

    init(spaceId: String) {
        _model = State(initialValue: WallpaperPickerViewModel(spaceId: spaceId))
    }
    
    var body: some View {
        VStack(alignment: .center) {
            DragIndicator()
            Spacer.fixedHeight(12)
            AnytypeText(Loc.changeWallpaper, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            Spacer.fixedHeight(12)
            WallpaperColorsGridView(spaceIcon: model.spaceIcon, currentWallpaper: model.wallpaper) { background in
                AnytypeAnalytics.instance().logSettingsWallpaperSet()
                model.wallpaper = background
                dismiss()
            }
        }
        .background(Color.Background.secondary)
        .onAppear {
            AnytypeAnalytics.instance().logScreenSettingsWallpaper()
        }
    }
}
