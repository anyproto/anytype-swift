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
                    generateFeedback()
                    viewModel.removeFromFavorite(data: cellData)
                }
            } else {
                Button(Loc.addToFavorite) {
                    generateFeedback()
                    viewModel.addToFavorite(data: cellData)
                }
            }
            
            if #available(iOS 15.0, *) {
                Button(Loc.moveToBin, role: .destructive) {
                    generateFeedback()
                    viewModel.moveToBin(data: cellData)
                }
            } else {
                Button(Loc.moveToBin) {
                    generateFeedback()
                    viewModel.moveToBin(data: cellData)
                }
            }
        }
    }
    
    private func generateFeedback() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
