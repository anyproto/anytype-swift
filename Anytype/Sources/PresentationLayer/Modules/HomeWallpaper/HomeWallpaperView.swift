import Foundation
import SwiftUI
import Services

struct HomeWallpaperView: View {
    
    @StateObject private var model: HomeWallpaperViewModel
    
    init(spaceId: String) {
        self._model = StateObject(wrappedValue: HomeWallpaperViewModel(spaceId: spaceId))
    }
    
    var body: some View {
        GeometryReader { geo in
            DashboardWallpaper(wallpaper: model.wallpaper, spaceIcon: model.spaceIcon)
                .frame(width: geo.size.width)
                .clipped()
                .ignoresSafeArea()
        }
        .task {
            await model.subscribeOnWallpaper()
        }
        .task {
            await model.subscribeOnSpace()
        }
    }
}
