import Foundation
import SwiftUI

struct EditorCoordinatorView: View {
    
    @StateObject var model: EditorCoordinatorViewModel
    @Environment(\.pageNavigation) var pageNavigation
    
    var body: some View {
        model.makeView()
            .onAppear {
                model.pageNavigation = pageNavigation
            }
    }
}
