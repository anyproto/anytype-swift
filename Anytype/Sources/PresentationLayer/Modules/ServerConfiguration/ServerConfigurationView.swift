import Foundation
import SwiftUI
import AnytypeCore

struct ServerConfigurationView: View {

    @StateObject private var model: ServerConfigurationViewModel
    
    init(output: (any ServerConfigurationModuleOutput)?) {
        _model = StateObject(wrappedValue: ServerConfigurationViewModel(output: output))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DragIndicator()
                TitleView(title: Loc.Server.network)
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(0..<model.mainRows.count, id: \.self) { rowIndex in
                            makeRow(row: model.mainRows[rowIndex])
                        }
                        
                        if model.rows.isNotEmpty {
                            SectionHeaderView(title: Loc.Server.networks)
                            
                            VStack(spacing: 0) {
                                ForEach(0..<model.rows.count, id: \.self) { rowIndex in
                                    makeRow(row: model.rows[rowIndex])
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                
                StandardButton(
                    Loc.Server.addButton,
                    style: .secondaryLarge)
                {
                    model.onTapAddServer()
                }
                .padding(16)
            }
            .background(Color.Background.secondary)
            .navigationBarHidden(true)
        }
        .anytypeSheet(isPresented: $model.showLocalConfigurationAlert) {
            ServerLocalConfigurationAlert {
                model.setup(config: .localOnly)
            }
        }
    }
    
    private func makeRow(row: ServerConfigurationRow) -> some View {
        Button {
            row.onTap()
        } label: {
            HStack {
                AnytypeText(row.title, style: .bodyRegular)
                    .foregroundStyle(Color.Text.primary)
                Spacer()
                if row.isSelected {
                    Image(asset: .X24.tick)
                        .foregroundStyle(Color.Text.primary)
                }
            }
            .frame(height: 48)
            .newDivider()
            .fixTappableArea()
        }
        .buttonStyle(.plain)
    }
}
