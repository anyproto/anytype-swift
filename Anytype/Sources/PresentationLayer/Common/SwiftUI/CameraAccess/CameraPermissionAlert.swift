import SwiftUI

extension View {
    
    func cameraPermissionAlert(isPresented: Binding<Bool>) -> some View {
        self
            .alert(Loc.Auth.cameraPermissionTitle, isPresented: isPresented, actions: {
                Button(
                    Loc.Alert.CameraPermissions.settings,
                    role: .cancel,
                    action: {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url)
                    }
                )
                Button(Loc.cancel, action: {})
            }, message: {
                Text(verbatim: Loc.Alert.CameraPermissions.goToSettings)
            })
    }
}
