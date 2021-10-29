import SwiftUI
import AnytypeCore

struct WallpaperPickerView: View {
    @EnvironmentObject var model: SettingsViewModel
    
    var body: some View {
        DragIndicator()
        AnytypeText("Change wallpaper".localized, style: .uxTitle1Semibold, color: .textPrimary)
            .multilineTextAlignment(.center)
        CoverColorsGridView() { background in
            model.wallpaper = background
            model.wallpaperPicker = false
        }
    }
}

struct WallpaperPickerView_Previews: PreviewProvider {
    static var previews: some View {
        WallpaperPickerView()
    }
}
