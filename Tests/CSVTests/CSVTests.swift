import XCTest
@testable import CSV

final class CSVCoreTests: XCTestCase {

    static var allTests = [
        ("test_file_0001", test_file_0001),
        ("test_file_0002", test_file_0002),
        ("test_file_0003", test_file_0003)
    ]
    
    func test_file_0001() {
        
        let url = Bundle.module.url(forResource: "test0001", withExtension: "csv")!
            
        var config = CSVConfig()
        config.eol = .LF
        config.format = .init(arrayLiteral:
                                nil, // FormatSpecifier.Text(encoding: .utf8),
                              FormatSpecifier.Number(),
                              FormatSpecifier.Number(format: NumberFormatter(",")),
                              FormatSpecifier.Number(),
                              FormatSpecifier.Date(format: DateFormatter("dd.MM.yyyy")),
                              FormatSpecifier.Date(format: DateFormatter("yyyy/MM/dd")),
                              FormatSpecifier.Date(format: DateFormatter("yyyy-MM-dd")))
        
        
        let file = try! CSVFile.read(from: url, with: config)
        

        XCTAssertEqual(file?.header, ["String","Number1","Number2","Number3","Date1","Date2","Date3"])
            
        XCTAssertEqual(file?.rows.count, 2)
        XCTAssertEqual(file?.rows[1].count, 7)
        XCTAssertEqual(file?.rows[1][0], CSVText("One"))
        XCTAssertEqual(file?.rows[1][1], CSVNumber(42.0))
        XCTAssertEqual(file?.rows[1][2], CSVNumber(23.32))
        XCTAssertEqual(file?.rows[1][3], CSVNumber(32.32))
        //XCTAssertEqual(file?.rows[0][4], CSVDate(DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2012, month: 12, day: 21, hour: 0, minute: 0, second: 0).date!))
        XCTAssertEqual(file?.rows[1][5], CSVDate(DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 02, hour: 0, minute: 0, second: 0).date!))
        XCTAssertEqual(file?.rows[1][6], CSVDate(DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 03, hour: 0, minute: 0, second: 0).date!))
        
    }
    
    func test_file_0002() {
        
        let url = Bundle.module.url(forResource: "test0002", withExtension: "csv")!
        
        var config = CSVConfig()
        config.eol = .CR_LF
        config.delimiter = Character(",").asciiValue!
        
        let file = try! CSVFile.read(from: url, with: config)
        
        XCTAssertEqual(file?.rows.count, 32446)
        XCTAssertEqual(file?.header, ["Year","Industry_aggregation_NZSIOC","Industry_code_NZSIOC","Industry_name_NZSIOC","Units","Variable_code","Variable_name","Variable_category","Value","Industry_code_ANZSIC06"])
        
        XCTAssertEqual(file?.rows[39], ["2019","Level 1","AA","Agriculture, Forestry and Fishing","Dollars (millions)","H10","Indirect taxes","Financial performance","475","ANZSIC06 division A"], "")
        
        file?.rows.forEach({ row in
            XCTAssertEqual(row.count, 10)
        })
        
    }
    
    func test_file_0003() {
        
        let url = Bundle.module.url(forResource: "test0003", withExtension: "csv")!
        
        var config = CSVConfig()
        config.eol = .LF
        config.delimiter = ";".utf8.map{$0}.first!
        
        let file = try? CSVFile.read(from: url, with: config)
        
        XCTAssertEqual(file?.rows.count, 6)
        XCTAssertEqual(file?.header, ["Username","Login email","Identifier","First name","Last name"])
        
        XCTAssertEqual(file?.rows[1].count, 5)
        XCTAssertEqual(file?.rows[1], ["booker12","rachel@example.com","9012","Rachel","Booker"])
    }
}
