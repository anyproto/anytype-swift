import Foundation
import SwiftUI

struct EditorPageCoordinatorView: View {
    
    @StateObject var model: EditorPageCoordinatorViewModel
    @Environment(\.pageNavigation) var pageNavigation
    
    var body: some View {
        model.pageModule()
            .ignoresSafeArea()
            .onAppear {
                model.pageNavigation = pageNavigation
            }
    }
}
