import SwiftUI

// https://github.com/Zi0P4tch0/Swift-UI-Views
extension View {

    func snackbar(isShowing: Binding<Bool>, text: AnytypeText, autohide: Snackbar.Autohide = .enabled(timeout: 2)) -> some View {
        Snackbar(isShowing: isShowing, presenting: self, text: text, autohide: autohide)
    }
    
}

