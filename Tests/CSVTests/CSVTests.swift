import XCTest
@testable import CSV

final class CSVCoreTests: XCTestCase {

    static var allTests = [
        ("testExample", testExample),
    ]
    
    func testExample() {
        // This is a n example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        let url = Bundle.module.url(forResource: "test0001", withExtension: "csv")!
        let data = try! Data(contentsOf: url)
        
        let x = CSVFile.read(data)
        print(x)
    }
    
    func test0001() {
        
        let url = Bundle.module.url(forResource: "test0001", withExtension: "csv")!
        let data = try! Data(contentsOf: url)
            
        let x = CSVFile.read(data, .init(arrayLiteral:
                                            nil, // FormatSpecifier.Text(encoding: .utf8),
                                         FormatSpecifier.Number(),
                                         FormatSpecifier.Number(seperator: ","),
                                         FormatSpecifier.Number(seperator: "."),
                                         FormatSpecifier.Date(format: "dd.MM.yyyy"),
                                         FormatSpecifier.Date(format: "yyyy/MM/dd"),
                                         FormatSpecifier.Date(format: "yyyy-MM-dd")
        ))
        print(x)
        
    }
}
