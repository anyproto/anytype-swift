import SwiftUI
import AnytypeCore
import BlocksModels

extension Image {
    static let appIcon = createImage("AppIcon")
    static let oldSchoolAppIcon = Image(uiImage: UIImage(imageLiteralResourceName: "oldSchool")) 
    static let artAppIcon = Image(uiImage: UIImage(imageLiteralResourceName: "art"))
//    static let logo = createImage("logo")
    static let splashLogo = createImage("splash_logo")
    
    static let arrow = createImage("arrowForward")
    static let arrowDown = createImage("arrowDown")
    
    static let checked = createImage("TextEditor/Text/checked")
    
    static let noImage = Image("no_image")
    
    static let ghost = createImage(ImageName.ghost)
    static let optionChecked = createImage("option_checked")
    
    static let plus = createImage("plus")
}

extension Image {
    enum `set` {
        static let forward = createImage("set_pagination_arrow_forward")
        static let back = createImage("set_pagination_arrow_backward")
        static let settings = createImage("set_settings")
        
        static let filter = createImage("set_settins_filter")
        static let group = createImage("set_settins_group")
        static let viewSettings = createImage("set_settins_settings")
        static let sort = createImage("set_settins_sort")
        static let view = createImage("set_settins_view")
    }
    
    enum main {
        static let draft = createImage("draft")
        static let search = createImage("main_search")
        static let settings = createImage("main_settings")
        static let marketplace = createImage("marketplace")
        static let selection = createImage("selection")
    }
    
    enum settings {
        static let account = createImage("settings_account_and_data")
        static let personalization = createImage("settings_personalization")
        static let appearance = createImage("settings_appearance")
        static let keychain = createImage("setings_set_keychain_phrase")
        static let about = createImage("settings_about")
        static let pin = createImage("settings_set_pin_code")
        static let wallpaper = createImage("settings_set_wallpaper")
        static let debug = createImage("settings_debug")
    }
    
    enum auth {
        static let photo = createImage("auth_photo_icon")
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
        static let relations = createImage("object_settings_relations")
    }

    enum ObjectAction {
        static let archive = createImage("delete")
        static let restore = createImage("restore")
        static let favorite = createImage("addToFavorites")
        static let unfavorite = createImage("unfavorite")
        static let undoRedo = createImage("undoredo")
        static let lock = createImage("lock")
        static let unlock = createImage("unlock")
        static let duplicate = createImage("duplicate")
    }
    
    enum LayoutSettings {
        static let basic = createImage("layout_settings_basic")
        static let note = createImage("layout_settings_note")
        static let profile = createImage("layout_settings_profile")
        static let todo = createImage("layout_settings_todo")
    }

    enum System {
        static let xmark = Image(systemName: "xmark")
        static let share = Image(systemName: "square.and.arrow.up")
        static let lassoAndSparkles = Image(systemName: "sparkles")
    }
    
    enum Relations {
        static let checkboxChecked = createImage("relation_checkbox_checked")
        static let checkboxUnchecked = createImage("relation_checkbox_unchecked")
        static let addToFeatured = createImage("relation_add_to_featured")
        static let removeFromFeatured = createImage("relation_remove_from_featured")
        static let locked = createImage("relation_locked")
        static let lockedSmall = createImage("relation_locked_small")
        
        static let createOption = createImage("relation_new")
    }

    enum ObjectPreview {
        static let card = createImage(ImageName.ObjectPreview.card)
        static let text = createImage(ImageName.ObjectPreview.text)
    }
}

extension Image {
    
    static func createImage(_ name: String) -> Image {
        guard let image = UIImage(named: name) else {
            anytypeAssertionFailure("No image named: \(name)", domain: .imageCreation)
            return .noImage
        }
        
        return Image(uiImage: image)
    }
    
}

private extension Image {
    
    private static func createSystemImage(_ name: String) -> Image {
        guard let image = UIImage(systemName: name) else {
            anytypeAssertionFailure("No system image named: \(name)", domain: .imageCreation)
            return .noImage
        }
        
        return Image(uiImage: image)
    }
}
