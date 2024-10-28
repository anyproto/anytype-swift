import Foundation

struct HomeBottomPanelState {
    
    private var hiddenStates: [AnyHashable: Bool] = [:]
    
    mutating func setHidden(_ hidden: Bool, for key: AnyHashable) {
        hiddenStates[key] = hidden
    }
    
    func hidden(for key: AnyHashable) -> Bool? {
        hiddenStates[key]
    }
}
