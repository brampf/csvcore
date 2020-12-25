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

/// Parser context information
struct ReaderContext {
    
    /// `CSVConfig` to use
    let config : CSVConfig
    
    /// Data Pointer
    internal var offset = 0
    /// Format overwrite (will always parse as `CSVText`
    internal var ignoreFormat = false
    /// do not parse the header
    internal var ignoreHead = false
    
    /// context for value parsing
    internal var valueIndex: Int = 0
    internal var valueStart: Int = 0
    internal var valueEnd: Int = 0
    
    mutating func reset() {
        
        self.offset = 0
        self.valueIndex = 0
        self.valueStart = 0
        self.valueEnd = 0
    }
}
