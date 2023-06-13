import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var key = ""
    @Published var autofocus = true
}
