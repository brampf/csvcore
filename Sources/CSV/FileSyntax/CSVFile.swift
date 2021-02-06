/*
 
 Copyright (c) <2020>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */
import Foundation
import FileReader

public struct CSVFile {
    
    public var header : CSVRow {
        get {
            rows[0]
        }
        set {
            if rows.isEmpty { rows = [newValue] }
            else { rows[0] = newValue }
        }
    }
    
    @Persistent public var rows : [CSVRow] = []
    
    public var maxRowCount : Int {
        
        rows.reduce(into: 0){ max,row in
            max = Swift.max(max, row.count)
        }
    }
    
    public var isIrregular : Bool {
        
        let max = maxRowCount
        return rows.contains { row in
            row.count != max
        }
        
    }
    
    /**
     Initializer
     */
    public init() {
        //
    }
    
    /**
     Initializer
     */
    public init(rows: [CSVRow] = []) {
        self.rows = rows
    }
    
    /**
     Initializer
     */
    public init(_ literals: [[CSVLiteral?]] = []) {
        self.rows = literals.csv
    }
}

extension CSVFile {
    

    
}
