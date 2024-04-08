import Foundation
import SwiftUI

struct ServerConfigurationView: View {

    @StateObject private var model: ServerConfigurationViewModel
    
    init(output: ServerConfigurationModuleOutput?) {
        _model = StateObject(wrappedValue: ServerConfigurationViewModel(output: output))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DragIndicator()
                TitleView(title: Loc.Server.network)
                
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            ForEach(0..<model.mainRows.count, id: \.self) { rowIndex in
                                makeRow(row: model.mainRows[rowIndex])
                            }
                        }
                        .cornerRadius(16, style: .continuous)
                        
                        if model.rows.isNotEmpty {
                            SectionHeaderView(title: Loc.Server.networks)
                            
                            VStack(spacing: 0) {
                                ForEach(0..<model.rows.count, id: \.self) { rowIndex in
                                    makeRow(row: model.rows[rowIndex])
                                }
                            }
                            .cornerRadius(16, style: .continuous)
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                StandardButton(Loc.Server.addButton, style: .secondaryMedium) {
                    model.onTapAddServer()
                }
                .padding(16)
            }
            .background(Color.Auth.modalBackground)
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
    
    private func makeRow(row: ServerConfigurationRow) -> some View {
        HStack {
            AnytypeText(row.title, style: .bodyRegular, color: .Auth.text)
            Spacer()
            if row.isSelected {
                Image(asset: .X24.tick)
                    .foregroundColor(.Auth.text)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 48)
        .fixTappableArea()
        .newDivider()
        .onTapGesture {
            row.onTap()
        }
        .background(Color.Auth.modalContent)
    }
}
