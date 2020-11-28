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
            
        let file = CSVFile.read(data, .init(arrayLiteral:
                                            nil, // FormatSpecifier.Text(encoding: .utf8),
                                         FormatSpecifier.Number(),
                                         FormatSpecifier.Number(seperator: ","),
                                         FormatSpecifier.Number(seperator: "."),
                                         FormatSpecifier.Date(format: "dd.MM.yyyy"),
                                         FormatSpecifier.Date(format: "yyyy/MM/dd"),
                                         FormatSpecifier.Date(format: "yyyy-MM-dd")
        ), eol: .LF)
        

        XCTAssertEqual(file?.header, ["String","Number1","Number2","Number3","Date1","Date2","Date3"])
            
        XCTAssertEqual(file?.rows.count, 1)
        XCTAssertEqual(file?.rows[0].count, 7)
        XCTAssertTrue(file!.rows[0][0].equals("One"))
        
    }
    
    func test0002() {
        
        let url = Bundle.module.url(forResource: "test0002", withExtension: "csv")!
        let data = try! Data(contentsOf: url)
        
        let file = CSVFile.read(data, eol: .CR_LF)
        
        XCTAssertEqual(file?.rows.count, 32445)
        XCTAssertEqual(file?.header, ["Year","Industry_aggregation_NZSIOC","Industry_code_NZSIOC","Industry_name_NZSIOC","Units","Variable_code","Variable_name","Variable_category","Value","Industry_code_ANZSIC06"])
        
        XCTAssertEqual(file?.rows[38] as? [String], ["2019","Level 1","AA","Agriculture, Forestry and Fishing","Dollars (millions)","H10","Indirect taxes","Financial performance","475","ANZSIC06 division A"])
        
        file?.rows.forEach({ row in
            XCTAssertEqual(row.count, 10)
        })
        
    }
}
