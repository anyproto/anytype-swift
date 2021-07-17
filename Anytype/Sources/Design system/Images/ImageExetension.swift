import SwiftUI


extension Image {
    static let logo = createImage("logo")
    static let arrow = createImage("arrowForward")
    
    static let checked = createImage("TextEditor/Style/Text/Checkbox/checked")
}

extension Image {
    enum main {
        static let draft = createImage("draft")
        static let search = createImage("main_search")
        static let settings = createImage("main_settings")
        static let marketplace = createImage("marketplace")
        
        static let wallpaper = createImage("default_home_wallpaper")
    }
    
    enum settings {
        static let keychain = createImage("setings_set_keychain_phrase")
        static let about = createImage("settings_about")
        static let pin = createImage("settings_set_pin_code")
        static let wallpaper = createImage("settings_set_wallpaper")
    }
    
    enum auth {
        static let qr = createImage("auth_qr_code")
        static let background = createImage("mainAuthBackground")
        static let photo = createImage("auth_photo_icon")
        static let congrats = createImage("auth_congrats")
    }
}

extension Image {
    
    enum SearchBar {
        static let magnifyingglass = createSystemImage("magnifyingglass")
        static let circleFill = createSystemImage("multiply.circle.fill")
    }
    
    enum ObjectSettings {
        static let icon = createImage("object_settings_icon")
        static let cover = createImage("object_settings_cover")
        static let layout = createImage("object_settings_layout")
    }
    
    enum LayoutSettings {
        static let basic = Image("layout_settings_basic")
        static let profile = Image("layout_settings_profile")
        static let todo = Image("layout_settings_todo")
        
        static let checkmark = Image("layout_settings_checkmark")
    }
}

private extension Image {
    
    private static func createImage(_ name: String) -> Image {
        guard let image = UIImage(named: name) else {
            assertionFailure("No image named: \(name)")
            return Image("no_image_blank_stub")
        }
        
        return Image(uiImage: image)
    }
    
    private static func createSystemImage(_ name: String) -> Image {
        guard let image = UIImage(systemName: name) else {
            assertionFailure("No system image named: \(name)")
            return Image("no_image_blank_stub")
        }
        
        return Image(uiImage: image)
    }
}
