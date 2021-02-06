import XCTest
import CSV

final class CSVValueTests: XCTestCase {
    
    static var allTests = [
        ("testCSVText", testCSVText),
        ("testCSVNumber", testCSVNumber),
        ("testCSVDate", testCSVDate)
    ]
        
 
    func testCSVText() {
        
        let x1 : CSVText = "Hello"
        let x2 : CSVText = "Hello"
        let x3 : CSVText = "World"
        
        XCTAssertEqual(x1, x2)
        XCTAssertEqual(x1.description, x2.description)
        XCTAssertNotEqual(x1.id, x2.id)
        XCTAssertNotEqual(x1.hashValue, x2.hashValue)
        
        XCTAssertNotEqual(x1, x3)
        XCTAssertNotEqual(x1.description, x3.description)
        XCTAssertNotEqual(x1.id, x3.id)
        XCTAssertNotEqual(x1.hashValue, x3.hashValue)
    }
    
    func testCSVNumber() {
        
        let x1 : CSVNumber = 23.43
        let x2 : CSVNumber = 23.43
        let x3 : CSVNumber = 42.23
        
        XCTAssertEqual(x1, x2)
        XCTAssertEqual(x1.description, x2.description)
        XCTAssertNotEqual(x1.id, x2.id)
        XCTAssertNotEqual(x1.hashValue, x2.hashValue)
        
        XCTAssertNotEqual(x1, x3)
        XCTAssertNotEqual(x1.description, x3.description)
        XCTAssertNotEqual(x1.id, x3.id)
        XCTAssertNotEqual(x1.hashValue, x3.hashValue)
        
    }
    
    func testCSVDate() {
        
        
        
    }
    
    func testCSVRow() {
        
        let row1 : CSVRow = [ "Test", 32.32, Date()]
        let row2 : CSVRow = [ "Test", 32.32, Date()]
        let row3 : CSVRow = [nil, nil, nil]
        let row4 : CSVRow = [nil, nil, nil]
        
        XCTAssertNotEqual(row1, row2)
        XCTAssertNotEqual(row1.hashValue, row2.hashValue)
        
        XCTAssertEqual(row3, row4)
    }
}
