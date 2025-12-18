import SwiftUI
import DesignKit

struct CircularTextView: View {
    let phrase: String
    let size: CGFloat
    let cornerRadius: CGFloat

    private let fontSize: CGFloat = 11

    private var fullText: String {
        let basePhrase = phrase.uppercased() + " "
        let perimeter = 4 * (size - 2 * cornerRadius) + 2 * .pi * cornerRadius
        let estimatedCharWidth = fontSize * 0.75
        let charsNeeded = Int(perimeter / estimatedCharWidth)

        var result = ""
        while result.count < charsNeeded {
            result += basePhrase
        }
        return result
    }

    init(phrase: String, size: CGFloat, cornerRadius: CGFloat = 24) {
        self.phrase = phrase
        self.size = size
        self.cornerRadius = cornerRadius
    }

    private var padding: CGFloat { fontSize }

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let cycleDuration: Double = 250
            let progress = elapsed.truncatingRemainder(dividingBy: cycleDuration) / cycleDuration

            Canvas { context, canvasSize in
                drawText(context: context, canvasSize: canvasSize, offset: progress)
            }
            .frame(width: size + padding * 2, height: size + padding * 2)
        }
    }

    private func drawText(context: GraphicsContext, canvasSize: CGSize, offset: Double) {
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let halfSize: CGFloat = size / 2
        let perimeter: CGFloat = 4 * (size - 2 * cornerRadius) + 2 * .pi * cornerRadius
        let charSpacing: CGFloat = perimeter / CGFloat(fullText.count)
        let characters = Array(fullText)

        for index in 0..<characters.count {
            let character = characters[index]
            let baseDistance = CGFloat(index) * charSpacing
            let distance = (baseDistance + CGFloat(offset) * perimeter)
                .truncatingRemainder(dividingBy: perimeter)
            let (point, angle) = positionOnRoundedRect(
                distance: distance,
                center: center,
                halfSize: halfSize,
                cornerRadius: cornerRadius
            )

            var ctx = context
            ctx.translateBy(x: point.x, y: point.y)
            ctx.rotate(by: angle)

            let text = Text(String(character))
                .font(AnytypeFontBuilder.font(anytypeFont: .tagline))
                .foregroundColor(Color.Text.secondary)

            ctx.draw(text, at: .zero)
        }
    }

    private func positionOnRoundedRect(
        distance: CGFloat,
        center: CGPoint,
        halfSize: CGFloat,
        cornerRadius: CGFloat
    ) -> (CGPoint, Angle) {
        let straightLength = size - 2 * cornerRadius
        let cornerArcLength = .pi / 2 * cornerRadius
        let segmentLengths: [CGFloat] = [
            straightLength,     // top
            cornerArcLength,    // top-right corner
            straightLength,     // right
            cornerArcLength,    // bottom-right corner
            straightLength,     // bottom
            cornerArcLength,    // bottom-left corner
            straightLength,     // left
            cornerArcLength     // top-left corner
        ]

        var remaining = distance
        var segmentIndex = 0

        while segmentIndex < segmentLengths.count && remaining > segmentLengths[segmentIndex] {
            remaining -= segmentLengths[segmentIndex]
            segmentIndex += 1
        }

        segmentIndex = segmentIndex % segmentLengths.count
        let t = remaining / segmentLengths[segmentIndex]

        let inset = halfSize - cornerRadius

        switch segmentIndex {
        case 0: // top edge (left to right)
            let x = center.x - inset + t * straightLength
            let y = center.y - halfSize
            return (CGPoint(x: x, y: y), .degrees(0))

        case 1: // top-right corner
            let cornerCenter = CGPoint(x: center.x + inset, y: center.y - inset)
            let angle = -(.pi / 2) + t * (.pi / 2)
            let x = cornerCenter.x + cornerRadius * cos(angle)
            let y = cornerCenter.y + cornerRadius * sin(angle)
            return (CGPoint(x: x, y: y), .radians(angle + .pi / 2))

        case 2: // right edge (top to bottom)
            let x = center.x + halfSize
            let y = center.y - inset + t * straightLength
            return (CGPoint(x: x, y: y), .degrees(90))

        case 3: // bottom-right corner
            let cornerCenter = CGPoint(x: center.x + inset, y: center.y + inset)
            let angle = t * (.pi / 2)
            let x = cornerCenter.x + cornerRadius * cos(angle)
            let y = cornerCenter.y + cornerRadius * sin(angle)
            return (CGPoint(x: x, y: y), .radians(angle + .pi / 2))

        case 4: // bottom edge (right to left)
            let x = center.x + inset - t * straightLength
            let y = center.y + halfSize
            return (CGPoint(x: x, y: y), .degrees(180))

        case 5: // bottom-left corner
            let cornerCenter = CGPoint(x: center.x - inset, y: center.y + inset)
            let angle = (.pi / 2) + t * (.pi / 2)
            let x = cornerCenter.x + cornerRadius * cos(angle)
            let y = cornerCenter.y + cornerRadius * sin(angle)
            return (CGPoint(x: x, y: y), .radians(angle + .pi / 2))

        case 6: // left edge (bottom to top)
            let x = center.x - halfSize
            let y = center.y + inset - t * straightLength
            return (CGPoint(x: x, y: y), .degrees(270))

        case 7: // top-left corner
            let cornerCenter = CGPoint(x: center.x - inset, y: center.y - inset)
            let angle = .pi + t * (.pi / 2)
            let x = cornerCenter.x + cornerRadius * cos(angle)
            let y = cornerCenter.y + cornerRadius * sin(angle)
            return (CGPoint(x: x, y: y), .radians(angle + .pi / 2))

        default:
            return (center, .zero)
        }
    }
}

#Preview {
    CircularTextView(phrase: Loc.connectWithMeOnAnytype, size: 280)
        .background(Color.gray.opacity(0.2))
}
