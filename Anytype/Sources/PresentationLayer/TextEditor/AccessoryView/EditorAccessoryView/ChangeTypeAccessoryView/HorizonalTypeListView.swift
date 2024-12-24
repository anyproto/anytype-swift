import SwiftUI
import UIKit
import Combine
import AnytypeCore


struct HorizonalTypeListView: View {
    @StateObject var viewModel: HorizonalTypeListViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 6) {
                searchButton
                pasteButton
                
                ForEach(viewModel.items) { item in
                    Button {
                        item.action()
                    } label: {
                        TypeView(icon: item.icon, title: item.title)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
        .frame(height: 52)
        .ignoresSafeArea()
        
        .task {
            viewModel.updatePasteState()
        }
        .task {
            await viewModel.handlePasteboard()
        }
    }
    
    var searchButton: some View {
        Button {
            viewModel.onSearchTap()
        } label: {
            IconView(icon: .asset(ImageAsset.X24.search))
                .frame(width: 24, height: 24)
                .padding(8)
        }
        .border(10, color: .Shape.secondary)
    }
    
    var pasteButton: some View {
        Group {
            if viewModel.showPaste {
                Button {
                    viewModel.onPasteButtonTap()
                } label: {
                    IconView(icon: .asset(ImageAsset.X24.clipboard))
                        .frame(width: 24, height: 24)
                        .padding(8)
                }
            }
        }
        .border(10, color: .Shape.secondary)
    }
}

private struct TypeView: View {
    let icon: Icon?
    let title: String

    var body: some View {
        HStack(spacing: 5) {
            if let icon {
                IconView(icon: icon)
                    .frame(width: 16, height: 16)
            }
            
            AnytypeText(title, style: .caption1Medium)
                .foregroundColor(.Text.primary)
                .lineLimit(1)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 12)
        .border(10, color: .Shape.secondary)
    }
}
