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
    struct DraggingData: Equatable {
        static func == (lhs: DocumentView.DraggingData, rhs: DocumentView.DraggingData) -> Bool {
            lhs.draggingRect == rhs.draggingRect && lhs.blockIndex == rhs.blockIndex
        }
        
        var draggingRect: CGRect
        var blockIndex: Int
        
        var draggingAnchor: Anchor<CGRect>? = nil
    }
    
    struct CurrentDropDividers {
        enum DividerType {
            case top
            case bottom
        }
        struct DividerData {
            var type: DividerType
            var idx: Int
            var rect: CGRect
            var isActive: Bool = false // if true block will be dropped in the area of this divider
        }
        var topDivider: DividerData
        var bottomDivider: DividerData
        
        var active: DividerData { // return divider where block will be dropped
            if topDivider.isActive {
                return topDivider
            } else {
                return bottomDivider
            }
        }
    }
    
    @Environment(\.showViewFrames) private var showViewFrames
    @State private var draggingData: DraggingData?
    @State private var currentDroppableData: CurrentDropDividers?
    @State private var droppableDividerRect: [CGRect]?
    @State private var droppableDividerAnchor: [DividerAnchorPreferenceData]?
    
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
        .scrollIfAnchorIntersectBoundary(anchor: self.draggingData?.draggingAnchor)
        .modifier(DraggingView(viewBulders: viewBulders, onStartDragging: {
            guard let count = self.droppableDividerRect?.count,
                let idx = self.draggingData?.blockIndex,
                count >= idx else { return }
            guard let top = self.droppableDividerRect?[idx], let bottom = self.droppableDividerRect?[idx + 1] else { return }
            
            let topDivider = CurrentDropDividers.DividerData(type: .top, idx: idx, rect: top)
            let bottomDivider = CurrentDropDividers.DividerData(type: .top, idx: idx, rect: bottom)
            
            self.currentDroppableData = CurrentDropDividers(topDivider: topDivider, bottomDivider: bottomDivider)
        }) {
            defer {
                self.currentDroppableData = nil
            }
            guard let dividerIdx = self.currentDroppableData?.active.idx else { return }
            guard let draggbleBlockIdx = self.draggingData?.blockIndex else { return }
            guard dividerIdx != draggbleBlockIdx, (dividerIdx + 1) != draggbleBlockIdx else { return }
            
            self.viewModel.moveBlock(fromIndex: draggbleBlockIdx, toIndex: dividerIdx)
        })
        .onGeometryPreferenceChange(DraggingViewCoordinatePreferenceKey.self, compute: { proxy, value in // save droppable divider rect
            if let anchor = value.position, let id = value.id {
                return DraggingData(draggingRect: proxy[anchor], blockIndex: id, draggingAnchor: value.position)
            }
            return nil
        }, onChange: { (value: DraggingData?) -> Void in
            self.draggingData = value
            
            if let draggingData = self.draggingData, let currentDroppableData = self.currentDroppableData, let droppableDividerRect = self.droppableDividerRect {
                self.currentDroppableData = self.defineDroppableDivider(draggingData: draggingData, currentDroppableDivider: currentDroppableData, droppableDividerRect: droppableDividerRect)
            }
        })
        .onGeometryPreferenceChange(DividerAnchorPreferenceKey.self, compute: { proxy, value in // save droppable divider rect
            var rects = [CGRect]()
            for preference in value {
                rects.append(proxy[preference.bounds])
            }
            return rects
        }, onChange: { (value:  [CGRect]?) -> Void in
            self.droppableDividerRect = value
            
            // update current droppable area divider
            guard let topDivider = self.currentDroppableData?.topDivider,
                let bottomDivider = self.currentDroppableData?.bottomDivider,
                let droppableDividerRect = self.droppableDividerRect else {
                    return
            }
            
            self.currentDroppableData?.topDivider.rect = droppableDividerRect[topDivider.idx]
            self.currentDroppableData?.bottomDivider.rect = droppableDividerRect[bottomDivider.idx]
            
            if let draggingData = self.draggingData, let currentDroppableData = self.currentDroppableData, let droppableDividerRect = self.droppableDividerRect {
                self.currentDroppableData = self.defineDroppableDivider(draggingData: draggingData, currentDroppableDivider: currentDroppableData, droppableDividerRect: droppableDividerRect)
            }
        })
        .environment(\.showViewFrames, true)
    }
    
    private func defineDroppableDivider(draggingData: DraggingData, currentDroppableDivider: CurrentDropDividers, droppableDividerRect: [CGRect]) -> CurrentDropDividers {
        var currentDroppableData = currentDroppableDivider

        // check where dragging view realated to dropAreaDivider
        // if dragging view upper top divider
        if draggingData.draggingRect.minY < currentDroppableData.topDivider.rect.minY {
            let upperDividerIdx = currentDroppableData.topDivider.idx - 1
            
            // check if it not last divider
            if upperDividerIdx < 0 {
                return currentDroppableData
            }
            
            let upperDividerRect = droppableDividerRect[upperDividerIdx]
            let upperDivider = CurrentDropDividers.DividerData(type: .top, idx: upperDividerIdx, rect: upperDividerRect)
            currentDroppableData = CurrentDropDividers(topDivider: upperDivider, bottomDivider: currentDroppableData.topDivider)
        } // if dragging view lower bottom divider
        else if draggingData.draggingRect.minY > currentDroppableData.bottomDivider.rect.minY {
            let lowerDividerIdx = currentDroppableData.topDivider.idx + 1
            
            // check if it not last divider
            if lowerDividerIdx > droppableDividerRect.count - 1 {
                return currentDroppableData
            }
            
            let lowerDividerRect = droppableDividerRect[lowerDividerIdx]
            let lowerDivider = CurrentDropDividers.DividerData(type: .top, idx: lowerDividerIdx, rect: lowerDividerRect)
            currentDroppableData = CurrentDropDividers(topDivider: currentDroppableData.bottomDivider, bottomDivider: lowerDivider)
        }
        
        // check which divider is active
        let topDivider = abs(draggingData.draggingRect.minY - currentDroppableData.topDivider.rect.maxY)
        let bottomDivider = abs(draggingData.draggingRect.minY - currentDroppableData.bottomDivider.rect.minY)
        
        if topDivider < bottomDivider {
            currentDroppableData.topDivider.isActive = true
        } else {
            currentDroppableData.bottomDivider.isActive = true
        }
        
        return currentDroppableData
    }
    
    private func makeBlockView(for index: Int, in builders: [BlockViewBuilderProtocol]) -> some View {
        let rowViewBuilder = builders[index]
        
        return VStack(spacing: 0) {
            ShowDroppableArea(droppableAreaId: index, currentDroppableAreaDividers: $currentDroppableData)
                .anchorPreference(key: DividerAnchorPreferenceKey.self, value: .bounds) { anchor in
                    [DividerAnchorPreferenceData(viewIdx: index, bounds: anchor)]
            }
            HStack {
                Spacer(minLength: 10)
                rowViewBuilder.buildView()
            }
            if index == (builders.count - 1) { // last one
                ShowDroppableArea(droppableAreaId: index + 1, currentDroppableAreaDividers: $currentDroppableData)
                    .anchorPreference(key: DividerAnchorPreferenceKey.self, value: .bounds) { anchor in
                        [DividerAnchorPreferenceData(viewIdx: index + 1, bounds: anchor)]
                }
            }
        }
    }
}


// MARK: - Building dropping area

private extension DocumentView {
    
    struct DividerAnchorPreferenceData {
        let viewIdx: Int
        let bounds: Anchor<CGRect>
    }
    
    struct DividerAnchorPreferenceKey: PreferenceKey {
        typealias Value = [DividerAnchorPreferenceData]
        
        static var defaultValue: [DividerAnchorPreferenceData] = []
        
        static func reduce(value: inout [DividerAnchorPreferenceData], nextValue: () -> [DividerAnchorPreferenceData]) {
            value.append(contentsOf: nextValue())
        }
    }
    
    struct ShowDroppableArea: View {
        @State var droppableAreaId: Int
        @Binding var currentDroppableAreaDividers: CurrentDropDividers?
        
        var body: some View {
            DropDividerView().opacity(droppableAreaId == currentDroppableAreaDividers?.active.idx ? 1.0 : 0.0)
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
        
        var id: Int? = nil
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
        
        var onStartDragging: () -> Void
        var onEndDragging: () -> Void
        
        func body(content: Content) -> some View {
            return content.overlayPreferenceValue(DraggingViewPreferenceKey.self) { preference in
                self.buildDraggingView(preference: preference)
            }
        }
        
        private func buildDraggingView(preference: DraggingViewPreferenceData) -> some View {
            let draggingViewIdx = viewBulders.firstIndex(where: { viewBuilder in
                viewBuilder.id == preference.id
            })
            var draggingView = AnyView(Color.clear)
            
            if let draggingViewIdx = draggingViewIdx {
                draggingView = viewBulders[draggingViewIdx].buildView()
            }
            
            return Group {
                if preference.isActive {
                    GeometryReader { proxy in
                        draggingView
                            .anchorPreference(key: DraggingViewCoordinatePreferenceKey.self, value: .bounds) {
                                return DraggingViewCoordinatePreferenceData(id: draggingViewIdx, position: $0, translation: preference.translation)
                        } // save dragging view anchor
                            .position(CGPoint(x: proxy[self.initialPosition ?? preference.position!].midX, y: proxy[self.initialPosition ?? preference.position!].midY))
                            .offset(x: preference.translation.width, y: preference.translation.height)
                    }
                    .opacity(0.5)
                    .colorInvert()
                    .onAppear {
                        self.onStartDragging()
                        self.initialPosition = preference.position
                    }
                    .onDisappear {
                        self.onEndDragging()
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
