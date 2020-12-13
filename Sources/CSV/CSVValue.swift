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

/**
 Wrapper for CSVLiteral types 
 */
public class CSVValue : Identifiable, Hashable, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    
    /// value id to distinguish two `CSVValue` objects with the same value
    public var id : Int {
        unsafeBitCast(self, to: Int.self)
    }
    
    internal init() {
        
    }
    
    public var description: String {
        return "CSVValue"
    }
    
    public var debugDescription: String {
        return String(format: "%p", id)
    }
    
    /**
     Hashes the id
     */
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /**
     Compares the value
     */
    public static func == (lhs: CSVValue, rhs: CSVValue) -> Bool {
        
        if let l = lhs as? CSVText, let r = rhs as? CSVText {
            return l.val == r.val
        }
        
        if let l = lhs as? CSVNumber, let r = rhs as? CSVNumber {
            return l.val == r.val
        }
        
        if let l = lhs as? CSVDate, let r = rhs as? CSVDate {
            return l.val == r.val
        }
        
        return false
    }
    
    /**
     Compares the value
     */
    public static func == (lhs: CSVValue, rhs: CSVLiteral) -> Bool {
        
        if let l = lhs as? CSVText, let r = rhs as? String {
            return l.val == r
        }
        
        if let l = lhs as? CSVNumber, let r = rhs as? Double {
            return l.val == r
        }
        
        if let l = lhs as? CSVDate, let r = rhs as? Date {
            return l.val == r
        }
        
        return false
    }
}

//MARK:- Equatable on Optional
extension Optional where Wrapped : CSVValue {
    
    /**
     Compares the value
     */
    public static func == <Literal: CSVLiteral>(lhs: Self, rhs: Literal?) -> Bool {
        
        if lhs == nil && rhs == nil {
            return true
        }
        
        if let l = lhs as? CSVText, let r = rhs as? String {
            return l.val == r
        }
        
        if let l = lhs as? CSVNumber, let r = rhs as? Double {
            return l.val == r
        }
        
        if let l = lhs as? CSVDate, let r = rhs as? Date {
            return l.val == r
        }
        
        return false
    }
    
}

public final class CSVNumber : CSVValue, ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    
    var val : Double
    
    public init(_ value: Double){
        self.val = value
    }
    
    public init(_ value: Int){
        self.val = Double(value)
    }
    
    public init(floatLiteral value: Double) {
        self.val = value
    }
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.val = Double(value)
    }
    
    override public var description: String {
        return val.description
    }
}

public final class CSVText : CSVValue, ExpressibleByStringLiteral {
    
    var val : String
    
    public init(_ value: String){
        self.val = value
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.val = value
    }

    override public var description: String {
        return val.description
    }
}

public final class CSVDate : CSVValue {
    
    var val : Date
    
    public init(_ value: Date) {
        self.val = value
    }
    
    public init?(_ from: DateComponents) {
        if let date = from.date {
            self.val = date
        } else {
            return nil
        }
    }
    
    override public var description: String {
        return val.description
    }
}
