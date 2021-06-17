 import Combine
 
 final class SettingSectionViewModel: ObservableObject {
    @Published var wallpaper: Bool = false
    @Published var keychain: Bool = false
    @Published var pincode: Bool = false
    @Published var about: Bool = false
}
