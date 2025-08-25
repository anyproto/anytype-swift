import XCTest
import AnytypeCore

class AnytypeURLTests: XCTestCase {
    
    private enum Constants {
        
        static let stringsFromBrowser = [
            "https://www.figma.com/file/zXl9RNoINX07RXg2qZtfKP/Mobile-–-WebClipper-%26-Bookmarks?node-id=12395%3A1153",
            "https://aliexpress.ru/item/1005001632872336.html?pdp_ext_f=%7B%22ship_from%22%3A%22RU%22%2C%22sku_id%22%3A%2212000019661167164%22%7D&pdp_npi=2%40dis%21RUB%2115%C2%A0444%2C15%20руб.%2110%C2%A0810%2C91%20руб.%21%21%21%21%21%4021135c3a16612697582432384ede90%2112000019661167164%21gdf&sku_id=12000019661167167&spm=a2g0o.tm800090009.9265972970.1.670a1fa2bYJ3bO",
            "https://en.wikipedia.org/wiki/Live_–_Friday_the_13th",
            "https://en.wikipedia.org/wiki/Canã_River",
            "https://честныйзнак.рф",
            "https://a/b#c"
        ]
        
        static let urls = [
            URL(string: "https://www.figma.com/file/zXl9RNoINX07RXg2qZtfKP/Mobile-%E2%80%93-WebClipper-&-Bookmarks?node-id=12395:1153")!,
            URL(string: "https://aliexpress.ru/item/1005001632872336.html?pdp_ext_f=%7B%22ship_from%22:%22RU%22,%22sku_id%22:%2212000019661167164%22%7D&pdp_npi=2@dis!RUB!15%C2%A0444,15%20%D1%80%D1%83%D0%B1.!10%C2%A0810,91%20%D1%80%D1%83%D0%B1.!!!!!@21135c3a16612697582432384ede90!12000019661167164!gdf&sku_id=12000019661167167&spm=a2g0o.tm800090009.9265972970.1.670a1fa2bYJ3bO")!,
            URL(string: "https://en.wikipedia.org/wiki/Live_%E2%80%93_Friday_the_13th")!,
            URL(string: "https://en.wikipedia.org/wiki/Can%C3%A3_River")!,
            URL(string: "https://xn--80ajghhoc2aj1c8b.xn--p1ai")!,
            URL(string: "https://a/b#c")!
        ]
        
        static let urlsToStrings = [
            "https://www.figma.com/file/zXl9RNoINX07RXg2qZtfKP/Mobile-–-WebClipper-&-Bookmarks?node-id=12395:1153",
            "https://aliexpress.ru/item/1005001632872336.html?pdp_ext_f={\"ship_from\":\"RU\",\"sku_id\":\"12000019661167164\"}&pdp_npi=2@dis!RUB!15 444,15 руб.!10 810,91 руб.!!!!!@21135c3a16612697582432384ede90!12000019661167164!gdf&sku_id=12000019661167167&spm=a2g0o.tm800090009.9265972970.1.670a1fa2bYJ3bO",
            "https://en.wikipedia.org/wiki/Live_–_Friday_the_13th",
            "https://en.wikipedia.org/wiki/Canã_River",
            "https://xn--80ajghhoc2aj1c8b.xn--p1ai",
            "https://a/b#c"
        ]
    }

    func test_createFromString_to_String() {
        
        let result = Constants.stringsFromBrowser.map { AnytypeURL(string: $0)?.absoluteString }
        
        XCTAssertEqual(Constants.stringsFromBrowser, result)
    }
    
    func test_createFromURLString_to_String() {
        
        let result = Constants.urlsToStrings.map { AnytypeURL(string: $0)?.absoluteString }
        
        XCTAssertEqual(Constants.urlsToStrings, result)
    }
    
    func test_createFromString_to_URL() {
        
        let result = Constants.stringsFromBrowser.map { AnytypeURL(string: $0)?.url }
        
        XCTAssertEqual(Constants.urls, result)
    }
    
    func test_createFromURLString_to_URL() {
        
        let result = Constants.stringsFromBrowser.map { AnytypeURL(string: $0)?.url }
        
        XCTAssertEqual(Constants.urls, result)
    }
    
    func test_createFromUrl_to_String() {
        
        let result = Constants.urls.map { AnytypeURL(url: $0).absoluteString }
        
        XCTAssertEqual(Constants.urlsToStrings, result)
    }
    
    func test_createFromUrl_to_URL() {
        
        let result = Constants.urls.map { AnytypeURL(url: $0).url }
        
        XCTAssertEqual(Constants.urls, result)
    }
}
