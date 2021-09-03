import SwiftUI
import AnytypeCore

extension Image {
    static let logo = createImage("logo")
    static let splashLogo = createImage("splashLogo")
    static let arrow = createImage("arrowForward")
    
    static let checked = createImage("TextEditor/Style/Text/Checkbox/checked")
    
    static let noImage = Image("no_image")
}

extension Image {
    enum main {
        static let draft = createImage("draft")
        static let search = createImage("main_search")
        static let settings = createImage("main_settings")
        static let marketplace = createImage("marketplace")
    }
    
    enum settings {
        static let keychain = createImage("setings_set_keychain_phrase")
        static let about = createImage("settings_about")
        static let pin = createImage("settings_set_pin_code")
        static let wallpaper = createImage("settings_set_wallpaper")
    }
    
    enum auth {
        static let qr = createImage("auth_qr_code")
        static let photo = createImage("auth_photo_icon")
        static let congrats = createImage("auth_congrats")
    }
}

extension Image {
    
    enum SearchBar {
        static let magnifyingGlass = createImage("searchTextFieldIcon")
        static let circleFill = createSystemImage("multiply.circle.fill")
    }
    
    enum ObjectSettings {
        static let icon = createImage("object_settings_icon")
        static let cover = createImage("object_settings_cover")
        static let layout = createImage("object_settings_layout")
    }
    
    enum LayoutSettings {
        static let basic = createImage("layout_settings_basic")
        static let profile = createImage("layout_settings_profile")
        static let todo = createImage("layout_settings_todo")
        
        static let checkmark = Image("layout_settings_checkmark")
    }
}

private extension Image {
    
    private static func createImage(_ name: String) -> Image {
        guard let image = UIImage(named: name) else {
            anytypeAssertionFailure("No image named: \(name)")
            return .noImage
        }
        
        return Image(uiImage: image)
    }
    
    private static func createSystemImage(_ name: String) -> Image {
        guard let image = UIImage(systemName: name) else {
            anytypeAssertionFailure("No system image named: \(name)")
            return .noImage
        }
        
        return Image(uiImage: image)
    }
}
