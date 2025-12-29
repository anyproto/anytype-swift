import Foundation
import SwiftUI

struct HomeUpdateSubmoduleView: View {
    
    @StateObject private var model = HomeUpdateSubmoduleViewModel()
    
    var body: some View {
        if model.showUpdateAlert {
            Button {
                model.onTapUpdate()
            } label: {
                HomeUpdateView()
            }
            .buttonStyle(.plain)
            .openUrl(url: $model.openUrl)
        }
    }
}
