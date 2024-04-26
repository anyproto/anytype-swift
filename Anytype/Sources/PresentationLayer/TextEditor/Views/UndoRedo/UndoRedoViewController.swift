import Foundation

final class UndoRedoViewController: AnytypePopup {
    
    convenience init(objectId: String) {
        self.init(
            contentView: UndoRedoView(objectId: objectId),
            floatingPanelStyle: true,
            configuration: .init(isGrabberVisible: false, dismissOnBackdropView: true)
        )
        
        backdropView.backgroundColor = .clear
    }
}
