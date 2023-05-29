import Foundation
import SwiftUI

protocol WallpaperPickerModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make() -> AnyView
}

final class WallpaperPickerModuleAssembly: WallpaperPickerModuleAssemblyProtocol {
    
    // MARK: - WallpaperPickerModuleAssemblyProtocol
    
    @MainActor
    func make() -> AnyView {
        let model = WallpaperPickerViewModel()
        let view = WallpaperPickerView(model: model)
        return view.eraseToAnyView()
    }
}
