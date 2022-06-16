import FloatingPanel

final class SortOptionsPopupLayout: AnytypePopupLayout {
    
    init() {
        let anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] = [
            .half: FloatingPanelLayoutAnchor(fractionalInset: 0.33, edge: .bottom, referenceGuide: .safeArea),
            .full: FloatingPanelLayoutAnchor(absoluteInset: 0, edge: .top, referenceGuide: .safeArea)
        ]
        
        super.init(initialState: .half, anchors: anchors)
        
    }
    
}
