import Foundation
import SwiftUI
import BlocksModels

struct HomeContextMenuView: View {
    
    let cellData: HomeCellData
    @EnvironmentObject private var viewModel: HomeViewModel
    
    var body: some View {
        Group {
            if cellData.isFavorite {
                Button("Remove From Favorite") {
                    viewModel.removeFromFavorite(data: cellData)
                }
            } else {
                Button("Add To Favorite") {
                    viewModel.addToFavorite(data: cellData)
                }
            }
            
            if #available(iOS 15.0, *) {
                Button("Move To Bin", role: .destructive) {
                    viewModel.moveToBin(data: cellData)
                }
            } else {
                Button("Move To Bin") {
                    viewModel.moveToBin(data: cellData)
                }
            }
        }
    }
}
