import Foundation
import SwiftUI

struct HomeUpdateSubmoduleView: View {
    
    @StateObject private var model = HomeUpdateSubmoduleViewModel()
    
    var body: some View {
        if model.showUpdateAlert {
            HomeUpdateView()
                .onTapGesture {
                    model.onTapUpdate()
                }
                .openUrl(url: $model.openUrl)
        }
    }
}
