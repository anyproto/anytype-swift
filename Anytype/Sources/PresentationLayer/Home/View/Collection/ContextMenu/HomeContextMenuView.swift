import Foundation
import SwiftUI
import BlocksModels

struct HomeContextMenuView: View {
    
    let cellData: HomeCellData
    @EnvironmentObject private var viewModel: HomeViewModel
    
    var body: some View {
        Group {
            if cellData.isFavorite {
                Button(Loc.removeFromFavorite) {
                    viewModel.removeFromFavorite(data: cellData)
                }
            } else {
                Button(Loc.addToFavorite) {
                    viewModel.addToFavorite(data: cellData)
                }
            }
            
            if #available(iOS 15.0, *) {
                Button(Loc.moveToBin, role: .destructive) {
                    viewModel.moveToBin(data: cellData)
                }
            } else {
                Button(Loc.moveToBin) {
                    viewModel.moveToBin(data: cellData)
                }
            }
        }
    }
}
