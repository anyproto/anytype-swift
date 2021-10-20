 import Combine
 
 final class SettingSectionViewModel: ObservableObject {
    @Published var wallpaper = false
    @Published var keychain = false
    @Published var pincode = false
    @Published var about = false
    @Published var debugMenu = false
}
