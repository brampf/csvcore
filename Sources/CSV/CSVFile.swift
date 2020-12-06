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

public struct CSVFile {
    
    public var header : [String] = []
    public var rows : [[CSVValue?]] = []
    
    /**
     Initializer
     */
    public init(header: [String] = [], rows: [[CSVValue?]] = []) {
        self.header = header
        self.rows = rows
    }
}

extension CSVFile {
    
    /**
    Read file from `URL`
     
     - Parameters:
        -  url: `URL` of the file to read
        -  options: `Data.ReadingOptions`
        - config: `CSVConfig` (optional) file configuration
     */
    public static func read(contentsOf url: URL, options: Data.ReadingOptions = [], config: CSVConfig = CSVConfig()) throws -> CSVFile? {
        
        let data = try Data(contentsOf: url, options: options)
        return self.read(data, config)
        
    }
    
    /**
     Read CSV data from `Data`
     
     - Parameters:
        - data: The `Data` to read from
        - config: `CSVConfig` (optional) file configuration
     */
    public static func read(_ data: Data,_ config: CSVConfig = CSVConfig()) -> CSVFile? {
        
        /// context is passed as reference so we can read / write without creating copies in memory for every node in the AST
        var context = ReaderContext(config: config)
        
        return data.withUnsafeBytes { bytes in
            CSVReader.read(bytes, context: &context)
        }
        
    }
    
}

