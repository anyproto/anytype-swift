import Foundation
import SwiftUI

protocol WallpaperPickerModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(spaceId: String) -> AnyView
}

final class WallpaperPickerModuleAssembly: WallpaperPickerModuleAssemblyProtocol {
    
    // MARK: - WallpaperPickerModuleAssemblyProtocol
    
    @MainActor
    func make(spaceId: String) -> AnyView {
        return WallpaperPickerView(
            model: WallpaperPickerViewModel(spaceId: spaceId)
        ).eraseToAnyView()
    }
}
