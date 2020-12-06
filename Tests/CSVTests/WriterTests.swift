import XCTest
@testable import CSV

final class WriterTests: XCTestCase {
    
    static var allTests = [
        ("testWriteLine", testWriteLine)
    ]
 
    
    func testWriteLine() {
        
        let file = CSVFile(header: ["One","Two","Three"], rows: [["First",23.32,Date(timeIntervalSince1970: 300000)],["Second", 42,Date(timeIntervalSince1970: 0) ]])
        
        let config = CSVConfig()
        
        var data = Data()
        try! file.write(to: &data, config: config)
        
        let result = String(data: data, encoding: .utf8)
        XCTAssertEqual(result, "\"One\",\"Two\",\"Three\"\n\"First\",\"23.32\",\"\(Date(timeIntervalSince1970: 300000).debugDescription)\"\n\"Second\",\"42\",\"\(Date(timeIntervalSince1970: 0).debugDescription)\"")
    }
    
    func testWriteLines() {
        
        let file = CSVFile(header: [], rows: [[11,12],[21,22],[31,32]])
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        
        var config = CSVConfig()
        config.format = [
            FormatSpecifier.Number(format: formatter),
            FormatSpecifier.Number(format: formatter)
        ]
        
        var data = Data()
        try! file.write(to: &data, config: config)
        
        let result = String(data: data, encoding: .utf8)
        XCTAssertEqual(result, "\"eleven\",\"twelve\"\n\"twenty-one\",\"twenty-two\"\n\"thirty-one\",\"thirty-two\"")
    }
}
