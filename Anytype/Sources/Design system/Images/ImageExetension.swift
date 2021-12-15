import SwiftUI
import AnytypeCore

extension Image {
    static let appIcon = createImage("AppIcon")
    static let oldSchoolAppIcon = Image(uiImage: UIImage(imageLiteralResourceName: "oldSchool")) 
    static let artAppIcon = Image(uiImage: UIImage(imageLiteralResourceName: "art"))
    static let logo = createImage("logo")
    static let splashLogo = createImage("splashLogo")
    static let arrow = createImage("arrowForward")
    
    static let checked = createImage("TextEditor/Text/checked")
    
    static let noImage = Image("no_image")
    
    static let ghost = createImage(ImageName.ghost)
    static let optionChecked = createImage("option_checked")
}

extension Image {
    enum main {
        static let draft = createImage("draft")
        static let search = createImage("main_search")
        static let settings = createImage("main_settings")
        static let marketplace = createImage("marketplace")
        static let selection = createImage("selection")
    }
    
    enum settings {
        static let keychain = createImage("setings_set_keychain_phrase")
        static let about = createImage("settings_about")
        static let pin = createImage("settings_set_pin_code")
        static let wallpaper = createImage("settings_set_wallpaper")
        static let debug = createImage("settings_debug")
        static let other = createImage("settings_other")
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
        static let moveTo = createImage("moveTo")
        static let template = createImage("addNew")
        static let search = createImage("search")
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
        
        static let createOption = createImage(ImageName.slashMenu.relations.addRelation)
        static let newRelationOption = createImage("relation_new")
        
        enum Icons {
            enum Small {
                static let phone = createImage("relation_small_phone_icon")
                static let email = createImage("relation_small_email_icon")
                static let goToURL = createImage("relation_small_go_to_url_icon")
            }
        }
    }
}

private extension Image {
    
    private static func createImage(_ name: String) -> Image {
        guard let image = UIImage(named: name) else {
            anytypeAssertionFailure("No image named: \(name)", domain: .imageCreation)
            return .noImage
        }
        
        return Image(uiImage: image)
    }
    
    private static func createSystemImage(_ name: String) -> Image {
        guard let image = UIImage(systemName: name) else {
            anytypeAssertionFailure("No system image named: \(name)", domain: .imageCreation)
            return .noImage
        }
        
        return Image(uiImage: image)
    }
}
