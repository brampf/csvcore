import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CSVCoreTests.allTests),
        testCase(ReaderTests.allTests),
        testCase(WriterTests.allTests)
    ]
}
#endif

@testable import CSV

func XCTAssertSame<Val: CSVValue>(_ lhs: CSVValue?, _ rhs: Val?, file: StaticString = #file, line: UInt = #line){
    
    if let lhs = lhs as? Val , let rhs = rhs {
        XCTAssertTrue(lhs.equals(rhs), "\(String(describing: lhs)) is not the same as \(String(describing: rhs))", file: file, line: line)
    } else if rhs == nil && lhs == nil {
        // alright then
    } else {
        XCTFail("\(String(describing: lhs)) is not the same as \(String(describing: rhs))", file: file, line: line)
    }
    
}

func XCTAssertSame<Val: CSVValue>(_ lhs: CSVValue?, _ rhs: Val?, _ message: String, file: StaticString = #file, line: UInt = #line){
    
    if let lhs = lhs as? Val, let rhs = rhs {
        XCTAssertTrue(lhs.equals(rhs), message, file: file, line: line)
    } else if rhs == nil && lhs == nil {
        // alright then
    } else {
        XCTFail(message, file: file, line: line)
    }
    
}

func XCTAssertSameRow(_ lhs: [CSVValue?]?, _ rhs: [CSVValue?], _ message: String, file: StaticString = #file, line: UInt = #line){
    
    guard lhs?.count == rhs.count else {
        XCTFail(message+" \(String(describing: lhs)) is not equal to \(rhs)")
        return
    }
    
    for idx in 0..<(lhs?.count ?? 0) {

        if lhs?[idx] != nil && rhs[idx] == nil {
            XCTFail(message+" \(String(describing: lhs)) is not equal to \(rhs)", file: file, line: line)
            return
        }
        if lhs?[idx] == nil && rhs[idx] != nil {
            XCTFail(message+" \(String(describing: lhs)) is not equal to \(rhs)", file: file, line: line)
            return
        }
        if let l = lhs?[idx] as? String, let r = rhs[idx] as? String{
            XCTAssertSame(l, r, file: file, line: line)
        }
        if let l = lhs?[idx] as? Double, let r = rhs[idx] as? Double{
            XCTAssertSame(l, r, file: file, line: line)
        }
        if let l = lhs?[idx] as? Date, let r = rhs[idx] as? Date{
            XCTAssertSame(l, r, file: file, line: line)
        }

    }
    
}

func XCTAssertSame(_ in: String, _ config: CSVConfig = CSVConfig(), _ out: [[CSVValue?]], _ message: String? = nil, file: StaticString = #file, line: UInt = #line){
    
    var context = ReaderContext(config: config)
    context.skipHead = true
    let parsed = `in`.data(using: .utf8)?.withUnsafeBytes({ ptr in
        CSVReader.read(ptr, context: &context)
    })
    
    XCTAssertEqual(parsed?.rows.count, out.count, "Number of rows mismatch: \(parsed?.rows.count ?? 0) is not equal to \(out.count)", file: file, line: line)
    
    if parsed?.rows.count != out.count {
        XCTFail("Number of rows differ: \(String(describing: parsed?.rows.count)) is not equal to \(out.count)")
        return
    }
    
    for idx in 0..<(parsed?.rows.count ?? 0){
        XCTAssertSameRow(parsed?.rows[idx], out[idx], "Row \(idx) differs:", file: file, line: line)
        
    }
    
}
