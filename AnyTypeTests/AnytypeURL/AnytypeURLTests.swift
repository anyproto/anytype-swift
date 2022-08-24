import XCTest
@testable import Anytype

class AnytypeURLTests: XCTestCase {
    
    private enum Constants {
        static let strings = [
            "https://www.figma.com/file/zXl9RNoINX07RXg2qZtfKP/Mobile-–-WebClipper-%26-Bookmarks?node-id=12395%3A1153",
            "https://aliexpress.ru/item/1005001632872336.html?pdp_ext_f=%7B%22ship_from%22%3A%22RU%22%2C%22sku_id%22%3A%2212000019661167164%22%7D&pdp_npi=2%40dis%21RUB%2115%C2%A0444%2C15%20руб.%2110%C2%A0810%2C91%20руб.%21%21%21%21%21%4021135c3a16612697582432384ede90%2112000019661167164%21gdf&sku_id=12000019661167167&spm=a2g0o.tm800090009.9265972970.1.670a1fa2bYJ3bO",
            "https://en.wikipedia.org/wiki/Live_–_Friday_the_13th",
            "https://en.wikipedia.org/wiki/Canã_River",
            "https://честныйзнак.рф"
        ]
        
        static let urls = [
            URL(string: "https://www.figma.com/file/zXl9RNoINX07RXg2qZtfKP/Mobile-%E2%80%93-WebClipper-%2526-Bookmarks?node-id=12395%253A1153")!,
            URL(string: "https://aliexpress.ru/item/1005001632872336.html?pdp_ext_f=%257B%2522ship_from%2522%253A%2522RU%2522%252C%2522sku_id%2522%253A%252212000019661167164%2522%257D&pdp_npi=2%2540dis%2521RUB%252115%25C2%25A0444%252C15%2520%D1%80%D1%83%D0%B1.%252110%25C2%25A0810%252C91%2520%D1%80%D1%83%D0%B1.%2521%2521%2521%2521%2521%254021135c3a16612697582432384ede90%252112000019661167164%2521gdf&sku_id=12000019661167167&spm=a2g0o.tm800090009.9265972970.1.670a1fa2bYJ3bO")!,
            URL(string: "https://en.wikipedia.org/wiki/Live_%E2%80%93_Friday_the_13th")!,
            URL(string: "https://en.wikipedia.org/wiki/Can%C3%A3_River")!,
            URL(string: "https://%D1%87%D0%B5%D1%81%D1%82%D0%BD%D1%8B%D0%B9%D0%B7%D0%BD%D0%B0%D0%BA.%D1%80%D1%84")!
        ]
    }

    func test_createFromString_to_String() {
        
        let result = Constants.strings.map { AnytypeURL(string: $0)?.absoluteString }
        
        XCTAssertEqual(Constants.strings, result)
    }
    
    func test_createFromString_to_URL() {
        
        let result = Constants.strings.map { AnytypeURL(string: $0)?.url }
        
        XCTAssertEqual(Constants.urls, result)
    }
    
    func test_createFromUrl_to_String() {
        
        let result = Constants.urls.map { AnytypeURL(url: $0).absoluteString }
        
        XCTAssertEqual(Constants.strings, result)
    }
    
    func test_createFromUrl_to_URL() {
        
        let result = Constants.urls.map { AnytypeURL(url: $0).url }
        
        XCTAssertEqual(Constants.urls, result)
    }
}
