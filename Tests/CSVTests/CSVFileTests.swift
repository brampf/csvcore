import XCTest
import CSV

final class CSVFileTests: XCTestCase {
    
    static var allTests = [
        ("testRowCount", testRowCount),
        ("testIsIrregular", testIsIrregular)
    ]

    func testRowCount() {
        
        var file = CSVFile()
        file.rows.append([CSVText("one")])
        
        XCTAssertEqual(file.rows.count, 1)
        XCTAssertEqual(file.maxRowCount, 1)
        
        file.rows.append(CSVRow(1,2,3))

        XCTAssertEqual(file.rows.count, 2)
        XCTAssertEqual(file.maxRowCount, 3)
        
        file.rows.append(CSVRow("Eins","Zwei"))
        
        XCTAssertEqual(file.rows.count, 3)
        XCTAssertEqual(file.maxRowCount, 3)
        
        file.rows.remove(at: 1)
        
        XCTAssertEqual(file.rows.count, 2)
        XCTAssertEqual(file.maxRowCount, 2)
        
        
        var file1 = CSVFile()
        file1.header = ["One","Two"]
        
        XCTAssertEqual(file1.maxRowCount, 2)
        
        file1.header = ["One","Two","Three"]
        
        XCTAssertEqual(file1.maxRowCount, 3)
        
        file1.header = ["One","Two"]
        
        XCTAssertEqual(file1.maxRowCount, 2)
        
        file1.rows.append(CSVRow(1,2,3))
        
        XCTAssertEqual(file1.maxRowCount, 3)
        
        file1.rows.append(CSVRow(4,5))
        
        XCTAssertEqual(file1.maxRowCount, 3)
        
        file1.rows.remove(at: 0)
        
        XCTAssertEqual(file1.maxRowCount, 2)
    }
    
    func testIsIrregular() {
        
        var file = CSVFile()
        
        XCTAssertEqual(file.isIrregular, false)
        
        file.rows.append(CSVRow(1,2,3,4))
        
        XCTAssertEqual(file.isIrregular, false)
        
        file.header = ["One","Two","Three","Four"]
        
        XCTAssertEqual(file.isIrregular, false)
        
        file.header = ["One","Two","Three"]
        
        XCTAssertEqual(file.isIrregular, true)
        
        file.rows.append(CSVRow(5,6,7,8))
        
        XCTAssertEqual(file.isIrregular, true)
        
        file.rows.remove(at: 0)
        
        XCTAssertEqual(file.isIrregular, false)
    }
}
