import Foundation
import SwiftUI

struct EditorSetCoordinatorView: View {
    
    @StateObject var model: EditorSetCoordinatorViewModel
    @Environment(\.pageNavigation) var pageNavigation
    
    var body: some View {
        model.setModule()
            .onAppear {
                model.pageNavigation = pageNavigation
            }
    }
}
