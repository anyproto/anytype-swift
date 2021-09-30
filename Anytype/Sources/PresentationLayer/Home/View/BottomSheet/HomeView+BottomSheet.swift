import SwiftUI

extension HomeView {
    func offsetChanged(_ offset: CGPoint) {
        let sheetOpenOffset: CGFloat = -5
        let sheetCloseOffset: CGFloat = 40
        
        if offset.y < sheetOpenOffset {
            withAnimation(.spring()) {
                if case .closed = bottomSheetState {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                bottomSheetState = .open
            }
        }
        if offset.y > sheetCloseOffset {
            withAnimation(.spring()) {
                if case .open = bottomSheetState {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
                bottomSheetState = .closed
            }
        }
    }
    
    func onDrag(_ translation: CGSize) {
        bottomSheetState = .drag(offset: translation.height)
    }
    
    func onDragEnd(_ translation: CGSize) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        bottomSheetState = .finishDrag(offset: translation.height)
    }
}
