import SwiftUI

struct SetSettingsData: Identifiable {
    let id = UUID()
    let setDocument: SetDocumentProtocol
    let viewId: String
    let mode: SetViewSettingsMode
}
