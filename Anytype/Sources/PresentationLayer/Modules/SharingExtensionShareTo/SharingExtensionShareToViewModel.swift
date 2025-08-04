import SwiftUI

@MainActor
final class SharingExtensionShareToViewModel: ObservableObject {
    
    private let data: SharingExtensionShareToData
    
    init(data: SharingExtensionShareToData) {
        self.data = data
    }
}
