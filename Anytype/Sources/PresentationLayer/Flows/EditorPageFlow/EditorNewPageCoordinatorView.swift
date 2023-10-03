import Foundation
import SwiftUI

struct EditorNewPageCoordinatorView: View {
    
    @StateObject var model: EditorNewPageCoordinatorViewModel
    @Environment(\.pageNavigation) var pageNavigation
    
    var body: some View {
        model.pageModule()
            .ignoresSafeArea()
            .onAppear {
                model.pageNavigation = pageNavigation
            }
    }
}
