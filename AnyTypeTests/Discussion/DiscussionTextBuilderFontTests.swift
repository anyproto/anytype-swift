import Testing
import Foundation
import ProtobufMessages
@testable import Anytype

@Suite
struct DiscussionTextBuilderFontTests {

    private let builder = DiscussionTextBuilder()

    // MARK: - Body styles return .calloutRegular

    @Test
    func paragraph_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .paragraph) == .calloutRegular)
    }

    @Test
    func description_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .description_) == .calloutRegular)
    }

    @Test
    func toggle_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .toggle) == .calloutRegular)
    }

    @Test
    func numbered_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .numbered) == .calloutRegular)
    }

    @Test
    func marked_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .marked) == .calloutRegular)
    }

    @Test
    func checkbox_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .checkbox) == .calloutRegular)
    }

    @Test
    func quote_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .quote) == .calloutRegular)
    }

    @Test
    func callout_returnsCalloutRegular() {
        #expect(builder.anytypeFont(for: .callout) == .calloutRegular)
    }

    // MARK: - Heading styles return correct fonts

    @Test
    func header1_returnsTitle() {
        #expect(builder.anytypeFont(for: .header1) == .title)
    }

    @Test
    func titleStyle_returnsTitle() {
        #expect(builder.anytypeFont(for: .title) == .title)
    }

    @Test
    func header2_returnsHeading() {
        #expect(builder.anytypeFont(for: .header2) == .heading)
    }

    @Test
    func header3_returnsSubheading() {
        #expect(builder.anytypeFont(for: .header3) == .subheading)
    }

    @Test
    func header4_returnsSubheading() {
        #expect(builder.anytypeFont(for: .header4) == .subheading)
    }
}
