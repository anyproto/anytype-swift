//
//  DocumentView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import Combine


struct DocumentView: View {
    @Environment(\.showViewFrames) private var showViewFrames
    @State private var possibleBlockIdForObtainingDrop: Int?
    @State private var draggingAnchor: Anchor<CGRect>?
    
    @ObservedObject var viewModel: DocumentViewModel
    
    init(viewModel: DocumentViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        if let builders = viewModel.blocksViewsBuilders {
            if builders.isEmpty {
                return AnyView(EmptyDocumentView(title: ""))
            } else {
                return AnyView(blocksView(viewBulders: builders))
            }
        } else {
            return AnyView(loading)
        }
    }
    
    var loading: some View {
        Text("Loading...")
            .foregroundColor(.gray)
    }
}


private extension DocumentView {
    
    func blocksView(viewBulders: [BlockViewBuilderProtocol]) -> some View {
        CustomScrollView {
            ForEach(0..<viewBulders.count, id: \.self) { index in
                self.makeBlockView(for: index, in: viewBulders)
                    .padding(.top, -10) // Workaround: remove spacing
            }
                .padding(.top, 10) // Workaround: adjust first item after removing spacing
        }
        .scrollIfAnchorIntersectBoundary(anchor: self.draggingAnchor)
        .modifier(DraggingView(viewBulders: viewBulders))
        .onPreferenceChange(DraggingViewCoordinatePreferenceKey.self) { preference in
            self.draggingAnchor = preference.position
        }
        .overlayPreferenceValue(SaveBlockAnchorPreferenceKey.self) { preferences in
            GeometryReader { proxy in
                return self.buildDroppingArea(proxy: proxy, preferences: preferences)
            }
        }
        .environment(\.showViewFrames, true)
    }
    
    private func makeBlockView(for index: Int, in builders: [BlockViewBuilderProtocol]) -> some View {
        let rowViewBuilder = builders[index]
        
        return VStack(spacing: 0) {
            HStack {
                Spacer(minLength: 10)
                rowViewBuilder.buildView()
                    .anchorPreference(key: SaveBlockAnchorPreferenceKey.self, value: .bounds) { anchor in
                        [SaveBlockAnchorPreferenceData(viewIdx: index, bounds: anchor)]
                }
                .modifier(ShowDroppableArea(viewId: index, possibleBlockIdForObtainingDrop: $possibleBlockIdForObtainingDrop))
                
            }
        }
    }
}

// MARK: - Building dropping area

private extension DocumentView {
    
    struct SaveBlockAnchorPreferenceData {
        let viewIdx: Int
        let bounds: Anchor<CGRect>
    }
    
    struct SaveBlockAnchorPreferenceKey: PreferenceKey {
        typealias Value = [SaveBlockAnchorPreferenceData]
        
        static var defaultValue: [SaveBlockAnchorPreferenceData] = []
        
        static func reduce(value: inout [SaveBlockAnchorPreferenceData], nextValue: () -> [SaveBlockAnchorPreferenceData]) {
            value.append(contentsOf: nextValue())
        }
    }
    
    func buildDroppingArea(proxy: GeometryProxy, preferences: [SaveBlockAnchorPreferenceData]) -> some View {
        for (i, preference) in preferences.enumerated() {
            let rect1 = proxy[preference.bounds]
            
            var rect2: CGRect = CGRect(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            
            if preferences.count > i + 1 {
                let preference = preferences[i + 1]
                rect2 = proxy[preference.bounds]
            }
            
            // get min x
            let minX = min(rect1.minX, rect2.minX)
            // get max x
            let maxX = max(rect1.maxX, rect2.maxX)
            // get min y
            let minY = rect1.midY
            // get max y
            let maxY = rect2.midY
            
            let dropArea = CGRect.frame(from: CGPoint(x: minX, y: minY), to: CGPoint(x: maxX, y: maxY))
            
            if let dragCoordinates = draggingAnchor,
                dropArea.contains(proxy[dragCoordinates].origin) {
                DispatchQueue.main.async {
                    self.possibleBlockIdForObtainingDrop =  preference.viewIdx
                }
            }
        }
        return Color.clear
    }
    
    struct ShowDroppableArea: ViewModifier {
        var viewId: Int
        @Binding var possibleBlockIdForObtainingDrop: Int?
        
        func body(content: Content) -> some View {
            return VStack(spacing: 0) {
                content
                DropDividerView().opacity(viewId == possibleBlockIdForObtainingDrop ? 1.0 : 0.0)
            }
        }
        
        private struct DropDividerView: View {
            var body: some View {
                return Rectangle()
                    .foregroundColor(Color.blue)
                    .frame(height: 4)
            }
        }
    }
}


// MARK: - Building dragging view

private extension DocumentView {
    
    struct DraggingViewCoordinatePreferenceData: Identifiable, Equatable {
        static func == (lhs: DocumentView.DraggingViewCoordinatePreferenceData, rhs: DocumentView.DraggingViewCoordinatePreferenceData) -> Bool {
            lhs.id == rhs.id && lhs.translation == rhs.translation
        }
        
        var id: String? = nil
        var position: Anchor<CGRect>? = nil
        var translation: CGSize = .zero
    }


    struct DraggingViewCoordinatePreferenceKey: PreferenceKey {
        typealias Value = DraggingViewCoordinatePreferenceData
        
        static var defaultValue = DraggingViewCoordinatePreferenceData()
        
        static func reduce(value: inout DraggingViewCoordinatePreferenceData, nextValue: () -> DraggingViewCoordinatePreferenceData) {
            value = nextValue()
        }
    }
    
    // TODO: Move to PasteDraggingView struct
    struct DraggingView: ViewModifier {
        var viewBulders: [BlockViewBuilderProtocol]
        @State var initialPosition: Anchor<CGRect>? // We need it due to original postion of dragging view could change (for example when we scrolling)
        
        func body(content: Content) -> some View {
            return content.overlayPreferenceValue(DraggingViewPreferenceKey.self) { preference in
                self.buildDraggingView(preference: preference)
            }
        }
        
        private func buildDraggingView(preference: DraggingViewPreferenceData) -> some View {
            let dragginView = viewBulders.first(where: { viewBuilder in
                viewBuilder.id == preference.id
            })?.buildView()
            
            return Group {
                if preference.isActive {
                    GeometryReader { proxy in
                        dragginView
                            .anchorPreference(key: DraggingViewCoordinatePreferenceKey.self, value: .bounds) {
                                return DraggingViewCoordinatePreferenceData(id: preference.id, position: $0, translation: preference.translation)
                        } // save dragging view anchor
                            .position(CGPoint(x: proxy[self.initialPosition ?? preference.position!].midX, y: proxy[self.initialPosition ?? preference.position!].midY))
                            .offset(x: preference.translation.width, y: preference.translation.height)
                    }
                    .opacity(0.5)
                    .colorInvert()
                    .onAppear {
                        self.initialPosition = preference.position
                    }
                    .onDisappear {
                        self.initialPosition = nil
                    }
                } else {
                    Color.clear
                        .onAppear {
                            self.initialPosition = nil
                    }
                }
            }
        }
    }
}


// MARK: - Preview

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DocumentViewModel(documentId: "1")
        
        return DocumentView(viewModel: viewModel)
    }
    
}
