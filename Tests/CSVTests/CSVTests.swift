import XCTest
@testable import CSV

final class CSVCoreTests: XCTestCase {

    static var allTests = [
        ("test0001", test0001),
        ("test0002", test0002)
    ]
    
    func test0001() {
        
        let url = Bundle.module.url(forResource: "test0001", withExtension: "csv")!
        let data = try! Data(contentsOf: url)
            
        var config = CSVConfig()
        config.eol = .LF
        config.format = .init(arrayLiteral:
                                nil, // FormatSpecifier.Text(encoding: .utf8),
                              FormatSpecifier.Number(),
                              FormatSpecifier.Number(format: NumberFormatter(",")),
                              FormatSpecifier.Number(format: NumberFormatter(".")),
                              FormatSpecifier.Date(format: DateFormatter("dd.MM.yyyy")),
                              FormatSpecifier.Date(format: DateFormatter("yyyy/MM/dd")),
                              FormatSpecifier.Date(format: DateFormatter("yyyy-MM-dd")))
        
        let file = CSVFile.read(data, config)
        

        XCTAssertEqual(file?.header, ["String","Number1","Number2","Number3","Date1","Date2","Date3"])
            
        XCTAssertEqual(file?.rows.count, 1)
        XCTAssertEqual(file?.rows[0].count, 7)
        XCTAssertSame(file?.rows[0][0], "One")
        XCTAssertSame(file?.rows[0][1], 42.0)
        XCTAssertSame(file?.rows[0][2], 23.32)
        XCTAssertSame(file?.rows[0][3], 32.32)
        XCTAssertSame(file?.rows[0][4], DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 12, day: 21, hour: 0, minute: 0, second: 0).date!)
        XCTAssertSame(file?.rows[0][5], DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 02, hour: 0, minute: 0, second: 0).date!)
        XCTAssertSame(file?.rows[0][6], DateComponents(calendar: Calendar.current, timeZone: TimeZone(secondsFromGMT: 0),  year: 2020, month: 11, day: 03, hour: 0, minute: 0, second: 0).date!)
        
    }
    
    func test0002() {
        
        let url = Bundle.module.url(forResource: "test0002", withExtension: "csv")!
        let data = try! Data(contentsOf: url)
        
        var config = CSVConfig()
        config.eol = .CR_LF
        
        let file = CSVFile.read(data, config)
        
        XCTAssertEqual(file?.rows.count, 32445)
        XCTAssertEqual(file?.header, ["Year","Industry_aggregation_NZSIOC","Industry_code_NZSIOC","Industry_name_NZSIOC","Units","Variable_code","Variable_name","Variable_category","Value","Industry_code_ANZSIC06"])
        
        XCTAssertSameRow(file?.rows[38], ["2019","Level 1","AA","Agriculture, Forestry and Fishing","Dollars (millions)","H10","Indirect taxes","Financial performance","475","ANZSIC06 division A"], "")
        
        file?.rows.forEach({ row in
            XCTAssertEqual(row.count, 10)
        })
        
    }
    
    func test0003() {
        
        let url = Bundle.module.url(forResource: "test0003", withExtension: "csv")!
        let data = try! Data(contentsOf: url)
        
        var config = CSVConfig()
        config.eol = .LF
        config.delimiter = ";".utf8.map{$0}.first!
        
        let file = CSVFile.read(data, config)
        
        XCTAssertEqual(file?.rows.count, 5)
        XCTAssertEqual(file?.header, ["Username","Login email","Identifier","First name","Last name"])
        
        XCTAssertEqual(file?.rows[0].count, 5)
        XCTAssertEqual(file?.rows[0] as? [String], ["booker12","rachel@example.com","9012","Rachel","Booker"])
        
    }
}
