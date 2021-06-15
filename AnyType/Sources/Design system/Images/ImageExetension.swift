import SwiftUI


extension Image {
    static let logo = Image("logo")
    static let arrow = Image("arrowForward")
    
    static let checked = Image("TextEditor/Style/Text/Checkbox/checked")
}

extension Image {
    enum main {
        static let draft = Image("draft")
        static let search = Image("main_search")
        static let settings = Image("main_settings")
        static let marketplace = Image("marketplace")
        
        static let wallpaper = Image("default_home_wallpaper")
    }
    
    enum settings {
        static let keychain = Image("setings_set_keychain_phrase")
        static let about = Image("settings_about")
        static let pin = Image("settings_set_pin_code")
        static let wallpaper = Image("settings_set_wallpaper")        
    }
    
    enum auth {
        static let qr = Image("auth_qr_code")
        static let background = Image("mainAuthBackground")
        static let photo = Image("auth_photo_icon")
        static let congrats = Image("auth_congrats")
    }
}

extension Image {
    
    enum SearchBar {
        static let magnifyingglass = Image(systemName: "magnifyingglass")
        static let circleFill = Image(systemName: "multiply.circle.fill")
    }
    
    enum ObjectSettings {
        static let icon = Image("object_settings_icon")
        static let cover = Image("object_settings_cover")
        static let layout = Image("object_settings_layout")
    }
    
}
