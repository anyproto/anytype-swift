import SwiftUI

struct PropertyFormatsData: Identifiable {
    let id = UUID()
    let format: SupportedPropertyFormat
    let onSelect: (SupportedPropertyFormat) -> Void
}
