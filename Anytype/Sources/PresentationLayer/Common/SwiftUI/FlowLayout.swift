/// https://talk.objc.io/episodes/S01E253-flow-layout-revisited

import SwiftUI

struct SizeKey: PreferenceKey {
    static let defaultValue: [CGSize] = []
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

func layout(sizes: [CGSize], spacing: CGSize = .init(width: 10, height: 10), containerWidth: CGFloat) -> [CGPoint] {
    var currentPoint: CGPoint = .zero
    var result: [CGPoint] = []
    var lineHeight: CGFloat = 0
    for size in sizes {
        if currentPoint.x + size.width > containerWidth {
            currentPoint.x = 0
            currentPoint.y += lineHeight + spacing.height
            lineHeight = 0
        }
        result.append(currentPoint)
        currentPoint.x += size.width + spacing.width
        lineHeight = max(lineHeight, size.height)
    }
    return result
}

struct FlowLayout<Element: Identifiable, Cell: View>: View {
    var items: [Element]
    var alignment: HorizontalAlignment = .leading
    var cell: (Element, Int) -> Cell

    @State private var sizes: [CGSize] = []
    @State private var containerWidth: CGFloat = 0

    var body: some View {
        let laidout = layout(sizes: sizes, containerWidth: containerWidth)

        return VStack(alignment: .leading, spacing: 0) {
            GeometryReader { proxy in
                Color.clear.preference(key: SizeKey.self, value: [proxy.size])
            }
            .frame(height: 0)
            .onPreferenceChange(SizeKey.self) { value in
                self.containerWidth = value[0].width
            }
            ZStack(alignment: .topLeading) {
                ForEach(Array(zip(items, items.indices)), id: \.0.id) { (item, index) in
                    cell(item, index)
                        .fixedSize()
                        .background(GeometryReader { proxy in
                            Color.clear.preference(key: SizeKey.self, value: [proxy.size])
                        })
                        .alignmentGuide(.leading, computeValue: { dimension in
                            guard !laidout.isEmpty, laidout.count > index else { return 0 }
                            return -laidout[index].x
                        })
                        .alignmentGuide(.top, computeValue: { dimension in
                            guard !laidout.isEmpty, laidout.count > index else { return 0 }
                            return -laidout[index].y
                        })
                }
            }
            .onPreferenceChange(SizeKey.self, perform: { value in
                self.sizes = value
            })
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

private struct Item: Identifiable, Hashable {
    var id = UUID()
    var value: String
}

private struct ContentView: View {
    @State var items: [Item] = (1...10).map { "Item \($0) " + (Bool.random() ? "\n" : "")  + String(repeating: "x", count: Int.random(in: 0...10)) }.map { Item(value: $0) }

    var body: some View {
        ScrollView {
            FlowLayout(items: items, cell: { item, _ in
                Text(item.value)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 5).fill(Color.blue))
            })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
