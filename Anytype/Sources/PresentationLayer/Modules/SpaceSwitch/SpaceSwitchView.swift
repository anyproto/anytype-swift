import SwiftUI

struct SpaceSwitchView: View {
    
    @StateObject var model: SpaceSwitchViewModel
    
    private let columns = [
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top)
    ]
    
    var body: some View {
        if #available(iOS 16.0, *) {
            contentContainer
                .presentationDetents([.height(380), .large])
                .presentationDragIndicator(.hidden)
                .presentationBackgroundLegacy(.ultraThinMaterial)
        } else {
            contentContainer
        }
    }
    
    private var contentContainer: some View {
        VStack {
            header
            content
        }
        .background(Color.Background.material)
    }
    
    private var content: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(model.rows) { row in
                    SpaceRowView(model: row)
                }
                SpacePlusRow(loading: model.spaceCreateLoading) {
                    model.onTapAddSpace()
                }
            }
            .padding([.top], 20)
            .animation(.default, value: model.rows.count)
        }
        .hideScrollIndicatorLegacy()
    }

    private var header: some View {
        VStack {
            DragIndicator()
            HStack {
                Spacer()
                AnytypeText(model.profileName, style: .heading, color: .Text.white)
                Spacer()
            }
            .overlay(rightButton, alignment: .trailing)
            .frame(height: 48)
            .padding(.horizontal, 16)
        }
    }
    
    private var rightButton: some View {
        Color.gray.frame(width: 32, height: 32)
    }
}

