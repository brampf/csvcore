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

public protocol CSVValue : CustomStringConvertible{
    
}

extension String : CSVValue {
    
}

extension Date : CSVValue {
    
}

extension Double : CSVValue {
    
}

extension Int : CSVValue {
    
}

extension CSVValue {
    
    public static func != (_ lhs: Self,_ rhs: Self) -> Bool {
        
        return !(lhs == rhs)
        
    }
    
    public static func == (_ lhs: Self,_ rhs: Self) -> Bool {

        return lhs.equals(rhs)
    }
    
    public func equals<Val: CSVValue>(_ rhs: Val) -> Bool {
        
        if let l = self as? String, let r = rhs as? String {
            return l == r
        }
        
        if let l = self as? Date, let r = rhs as? Date {
            return l == r
        }
        
        if let l = self as? Double, let r = rhs as? Double {
            return l == r
        }
        
        if let l = self as? Int, let r = rhs as? Int {
            return l == r
        }
        
        return false
    }
}

extension Optional where Wrapped == CSVValue {
    
    public func equals<Val : CSVValue>(_ rhs : Val) -> Bool {
        
        if let me = self {
            return me.equals(rhs)
        } else {
            return false
        }
    }
    
}

extension Array where Element: CSVValue {
    
    func equals(_ rhs: Self) -> Bool {
        
        guard self.count == rhs.count else {
            return false
        }
        
        for idx in 0..<self.count {
            if !(self[idx] == rhs[idx]){
                return false
            }
        }
        return true
    }
    
}
