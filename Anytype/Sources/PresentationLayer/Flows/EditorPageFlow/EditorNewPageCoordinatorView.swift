import Foundation
import SwiftUI

struct EditorNewPageCoordinatorView: View {
    
    @StateObject var model: EditorNewPageCoordinatorViewModel
    
    var body: some View {
        model.pageModule()
            .ignoresSafeArea()
    }
}
