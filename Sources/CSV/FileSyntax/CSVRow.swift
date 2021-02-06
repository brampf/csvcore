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

/// A row in the CSV File
public struct CSVRow : RandomAccessCollection, MutableCollection {
    public typealias Element = CSVValue?
    public typealias Index = Int
    
    var values : [Element] = []
    
    public subscript(position: Int) -> CSVValue? {
        get {
            values[position]
        }
        set {
            values[position] = newValue
        }
    }
    
    public var count : Int {
        values.count
    }
    
    public var startIndex: Int {
        values.startIndex
    }
    
    public var endIndex: Int {
        values.endIndex
    }
    
    public func index(before i: Int) -> Int {
        values.index(before: i)
    }
    
    public func index(after i: Int) -> Int {
        values.index(after: i)
    }
    
    public mutating func append(_ newElement: Element) {
        values.append(newElement)
    }
    
}

extension CSVRow : ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = CSVLiteral?
    
    public init(arrayLiteral elements: CSVLiteral?...){
        let row : [CSVValue?] = elements.map{ val in
            
            switch val {
            case let val as String: return CSVText(val)
            case let val as Double: return CSVNumber(val)
            case let val as Date: return CSVDate(val)
            default: return nil
            }
            
        }
        
        self.init(values: row)
    }
}

extension CSVRow : Equatable, Hashable {
    
    public init(_ elements: CSVValue...){
        self.values = elements
    }
    
    public init<S: Sequence>(_ s: S) where S.Element == CSVValue? {
        self.init(values: Array(s))
    }
    
    public init<S: Sequence>(_ s: S) where S.Element == CSVLiteral? {
        
        let row : [CSVValue?] = s.map{ val in
            
            switch val {
            case let val as String: return CSVText(val)
            case let val as Double: return CSVNumber(val)
            case let val as Date: return CSVDate(val)
            default: return nil
            }
            
        }
        
        self.init(values: row)
    }
    
    public static func == (lhs: CSVRow, rhs: CSVRow) -> Bool {
        return lhs.elementsEqual(rhs)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(values)
    }
}
