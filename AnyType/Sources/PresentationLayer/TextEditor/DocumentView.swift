//
//  DocumentView.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct DocumentView: View {
    @Environment(\.showViewFrames) private var showViewFrames
    
    @ObservedObject var viewModel: DocumentViewModel
    @State var dragCoordinates: CGRect? = nil
    @State var blocksRects: [CGRect] // blocks' rects
    @State var velocity: CGPoint = .zero
    
    init(viewModel: DocumentViewModel) {
        self.viewModel = viewModel
        _blocksRects = State(initialValue: [CGRect]())
        
        if let builders = viewModel.blocksViewsBuilders {
            _blocksRects = State(initialValue: Array<CGRect>(repeating: CGRect.zero, count: builders.count))
        }
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
}


private extension DocumentView {
    
    func blocksView(viewBulders: [BlockViewRowBuilderProtocol]) -> some View {
        CustomScrollView() {
            ForEach(0..<viewBulders.count, id: \.self) { index in
                self.makeBlockView(for: index, in: viewBulders)
                    .padding(.top, -10) // Workaround: remove spacing
            }
                .padding(.top, 10) // Workaround: adjust first item after removing spacing
                .coordinateSpace(name: "DocumentViewScrollCoordinateSpace")
                .backgroundPreferenceValue(BaseViewPreferenceKey.self) {preference in
                    GeometryReader { proxy in
                        self.convertDragRectFromAnchor(preference: preference, in: proxy)
                    }
            }
        }
        .scrollViewOffset(offset: self.velocity)
        .overlayPreferenceValue(BaseViewPreferenceKey.self) { preference in
            if preference.view != nil {
                preference.view
            }
        }
        .modifier(VelocityOnIntersectViewBoundary(velocity: self.$velocity))
        .border(showViewFrames ? Color.red : Color.clear)
    }
    
    private func makeBlockView(for index: Int, in builders: [BlockViewRowBuilderProtocol]) -> some View {
        let rowViewBuilder = builders[index]
        
        return VStack(spacing: 0) {
            HStack {
                Spacer(minLength: 10)
                rowViewBuilder.buildView().modifier(ShowViewOnRectIntersect(blocksRects: self.$blocksRects, dragCoordinates: self.$dragCoordinates, index: index))
            }
        }
    }
    
    // Convert anchor drag to frame in current ccoordinates
    private func convertDragRectFromAnchor(preference: BaseViewPreferenceData, in proxy: GeometryProxy) -> some View {
        if preference.isDragging, let dragRect = preference.dragRect {
            self.dragCoordinates = proxy[dragRect]
        } else {
            self.dragCoordinates = nil
        }
        return Color.clear
    }
    
    var loading: some View {
        Text("Loading...")
            .foregroundColor(.gray)
    }
}


struct VelocityOnIntersectViewBoundary: ViewModifier {
    @Binding var velocity: CGPoint
    @Environment(\.showViewFrames) private var showViewFrames
    
    private struct VelocityKey: PreferenceKey {
        
        static var defaultValue: CGPoint {
            .zero
        }
        
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = nextValue()
        }
    }
    
    func body(content: Content) -> some View {
        return content
            .overlayPreferenceValue(BaseViewPreferenceKey.self) { preference in
                GeometryReader { proxy in
                    self.obtainBoundary(proxy: proxy, preference: preference)
                }
        }
            .onPreferenceChange(VelocityKey.self) { velocity in
                self.velocity = velocity
        }
    }
    
    private func obtainBoundary(proxy: GeometryProxy, preference: BaseViewPreferenceData) -> some View {
        var velocity = CGPoint(x: 0, y: 0)
        
        let frame = proxy.frame(in: .local)
        let upperBoundary = CGRect(origin: .zero, size: CGSize(width: frame.width, height: frame.height * 0.15))
        
        let bottomY = frame.maxY - frame.height * 0.15
        let bottomOrigin = CGPoint(x: frame.minX, y: bottomY)
        let bottomBoundary = CGRect(origin: bottomOrigin, size: CGSize(width: frame.width, height: frame.height * 0.15))
        
        if let anchorDragRect = preference.dragRect, preference.isDragging {
            if upperBoundary.intersects(proxy[anchorDragRect]) {
                velocity = CGPoint(x: 0, y: -10)
            } else if bottomBoundary.intersects(proxy[anchorDragRect]) {
                velocity = CGPoint(x: 0, y: 10)
            }
        }
        
        return ZStack {
            Color.clear
            
            if showViewFrames {
                Rectangle()
                    .stroke(Color.green)
                    .frame(width: upperBoundary.width, height: upperBoundary.height)
                    .position(x: upperBoundary.midX, y: upperBoundary.midY)
                Rectangle()
                    .stroke(Color.blue)
                    .frame(width: bottomBoundary.width, height: bottomBoundary.height)
                    .position(x: bottomBoundary.midX, y: bottomBoundary.midY)
            }
        }
        .preference(key: VelocityKey.self, value: velocity)
    }
}


struct ShowViewOnRectIntersect: ViewModifier {
    @State private var dropCoordinate: CGRect?
    @Binding var blocksRects: [CGRect]
    @Binding var dragCoordinates: CGRect?
    var index: Int
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
                .background(
                    GeometryReader { proxy in
                        self.obtainCoordinates(proxy: proxy)
                    }
            )
            
            if showContent() {
                DropDividerView()
            } else {
                DropDividerView().hidden()
            }
        }
    }
    
    private func obtainCoordinates(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            let frame = proxy.frame(in: .named(String("DocumentViewScrollCoordinateSpace")))
            self.blocksRects[self.index] = frame
        }
        
        return Color.clear
    }
    
    private func showContent() -> Bool {
        let rect1 = blocksRects[index]
        var rect2: CGRect = CGRect(x: CGFloat.greatestFiniteMagnitude, y: CGFloat.greatestFiniteMagnitude, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
        if blocksRects.count > index + 1 {
            rect2 = blocksRects[index + 1]
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
        
        if let dragCoordinates = dragCoordinates, dropArea.contains(dragCoordinates.origin) {
            return true
        }
        return false
    }
}

struct DropDividerView: View {
    
    var body: some View {
        Rectangle()
            .foregroundColor(Color.blue)
            .frame(height: 4)
    }
}

struct DocumentView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DocumentViewModel(documentId: "1")
        
        return DocumentView(viewModel: viewModel)
    }
    
}
