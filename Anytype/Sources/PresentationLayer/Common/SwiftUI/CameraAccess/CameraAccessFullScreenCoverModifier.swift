import SwiftUI

extension View {
    func cameraAccessFullScreenCover<Target: View, Item: Identifiable>(item: Binding<Item?>, @ViewBuilder targetScreen: @escaping (Item) -> Target) -> some View {
        modifier(CameraAccessFullScreenCoverModifier(item: item, targetScreen: targetScreen))
    }
}

private struct CameraAccessFullScreenCoverModifier<Target: View, Item: Identifiable>: ViewModifier {
    
    @StateObject private var model = CameraAccessFullScreenCoverModifierModel<Item>()
    
    @Binding var item: Item?
    @ViewBuilder var targetScreen: (_ item: Item) -> Target
    
    func body(content: Content) -> some View {
        content
            .onChange(of: item?.id) {
                model.isPresentedUpdated(item)
            }
            .cameraPermissionAlert(isPresented: $model.openPermissionAlert)
            .fullScreenCover(item: $model.openTargetScreen, onDismiss: {
                item = nil
            }, content: {
                targetScreen($0)
            })
    }
}

@MainActor
private final class CameraAccessFullScreenCoverModifierModel<Item>: ObservableObject {
    
    @Injected(\.cameraPermissionVerifier)
    private var cameraPermissionVerifier: any CameraPermissionVerifierProtocol
    
    @Published var openPermissionAlert: Bool = false
    @Published var openTargetScreen: Item?
    
    func isPresentedUpdated(_ newValue: Item?) {
        guard let newValue else {
            openPermissionAlert = false
            openTargetScreen = nil
            return
        }
        
        Task {
            let isAllow = await cameraPermissionVerifier.cameraIsGranted()
            if !isAllow {
                openPermissionAlert = true
            } else {
                openTargetScreen = newValue
            }
        }
    }
}
