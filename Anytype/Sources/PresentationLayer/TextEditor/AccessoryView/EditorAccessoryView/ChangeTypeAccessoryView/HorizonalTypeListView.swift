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
                
                ForEach(viewModel.items) { item in
                    Button {
                        item.action()
                    } label: {
                        TypeView(emoji: item.emoji, title: item.title)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
        .frame(height: 52)
        .ignoresSafeArea()
    }
    
    var searchButton: some View {
        Button {
            viewModel.onSearchTap()
        } label: {
            IconView(icon: .asset(ImageAsset.X24.search))
                .frame(width: 24, height: 24)
                .padding(8)
        }
        .border(10, color: .Stroke.secondary)
    }
}

private struct TypeView: View {
    let emoji: Emoji?
    let title: String

    var body: some View {
        HStack(spacing: 5) {
            if let emoji {
                AnytypeText(emoji.value, style: .caption1Medium, color: .Text.primary)
            }
            
            AnytypeText(title, style: .caption1Medium, color: .Text.primary)
                .lineLimit(1)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 12)
        .border(10, color: .Stroke.secondary)
    }
}
