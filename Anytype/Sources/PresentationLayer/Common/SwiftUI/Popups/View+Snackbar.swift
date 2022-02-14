import SwiftUI

// https://github.com/Zi0P4tch0/Swift-UI-Views
extension View {

    func snackbar(isShowing: Binding<Bool>, text: AnytypeText) -> some View {
        Snackbar(isShowing: isShowing, presenting: self, text: text)
    }

}

