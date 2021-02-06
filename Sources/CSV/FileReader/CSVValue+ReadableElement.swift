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

extension CSVValue : ReadableElement {
    
    public static func size<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C) -> Int? {
        nil
    }
    
    public var byteSize: Int {
        0
    }
    
    
    public static func new<C: Context>(_ bytes: UnsafeRawBufferPointer, with context: inout C, _ symbol: String? = nil) throws -> Self? {
    
        guard let context = context as? CSVReaderContext else {
            return nil
        }
        
        var spec : FormatSpecifier? = nil
        if !context.ignoreFormat, !context.config.format.isEmpty,  context.valueIndex < context.config.format.count{
            spec = context.config.format[context.valueIndex]
        }
        
        let start = context.valueStart
        let end = context.valueEnd
        
        // we hit an empty value aka ",,"
        if start == end {
            return nil
        }
        
        // now parse the value
        var value : CSVValue?
        switch spec {
        case .Text(let encoding):
            value = try CSVText(bytes[start..<end], with: encoding)
        case .Number(let format):
            value = try CSVNumber(bytes[start..<end], with: format) ?? CSVText(bytes[start..<end], with: .utf8)
        case .Date(let format):
            value = try CSVDate(bytes[start..<end], with: format) ?? CSVText(bytes[start..<end], with: .utf8)
        case .none:
            // without context, we try to read text
            value = try CSVText(bytes[start..<end], with: .utf8)
        }
        //print("\(start)...\(end); val \(context.valueIndex) = \(value.debugDescription)")
        
        // increment value count
        context.valueIndex += 1
        // move the word pointer
        context.valueStart = end
        
        return value as? Self
    }
}

