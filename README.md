<p align="center">
<img src = "Doc/CSVBanner@0.5x.png" alt="CSVCore">
</p>

<p align="center">
<a href="LICENSE.md">
<img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
</a>
<a href="https://swift.org">
<img src="https://img.shields.io/badge/swift-5.3-brightgreen.svg" alt="Swift 5.3">
</a>
<img src="https://img.shields.io/github/languages/top/brampf/csvcore?color=bright" alt="Language">
<img src="https://img.shields.io/github/workflow/status/brampf/csvcore/Swift" alt="Swift">
</p>

A native Swift library to read and write CSV files

## Description
CSVCore is a pure Swift library to read and write files in the CSV file format.

## Features
* Read & Write CSV files
    * Custom delimiters (comma, semicolon)
    * Custom linefeeds (LF, CR, CR_LF)
* Parsing of native value types
    * Text with individual encodings per column
    * Numbers with individual formats per column using NumberFormatter
    * Dates with individual formats per column using DateFormatter
* Native code
    * Swift 5.3
    * Compiles for macCatalyst
    * Compiles for iPadOS
    * Compiles for Linux

## Getting started

### Package Manager

With the swift package manager, add the library to your dependencies
```swift
dependencies: [
.package(url: "https://github.com/brampf/csvcore.git", from: "0.1.0")
]
```

then simply add the `CSV` import to your target

```swift
.target(name: "YourApp", dependencies: ["CSV"])
```

## Documentation

### TL;DR

#### Reading CSV Files
```swift
import CSV

/// Parste a "standard" CSV with (,"LF)
let url =  URL("/path/to/some/csv/file")!
let file = try! CSVFile.read(from: url)
```

#### Tweaking the details
```swift
import CSV

/// Parste a "non standard" CSV with (;"CR_LF)

var config = CSVConfig()
config.eol = .CR_LF
config.delimiter = Character(",").asciiValue!

let url = URL("/path/to/some/csv/file")!
let file = try! CSVFile.read(contentsOf: url, config: config)
```

### Parsing specific value formats
```swift
import CSV

/// Parste a "non standard" CSV with (;"CR_LF)

var config = CSVConfig()
config.eol = .CR_LF
config.delimiter = Character(",").asciiValue!

let url = URL("/path/to/some/csv/file")!
let file = try! CSVFile.read(contentsOf: url, config: config)
```

#### Writing CSV Files
```swift
import CSV

let file = CSVFile(header: [], rows: [[11,12],[21,22],[31,32]])

// spell them out instead of numeric values
let formatter = NumberFormatter()
formatter.numberStyle = .spellOut

var config = CSVConfig()
config.format = [
    FormatSpecifier.Number(format: formatter),
    FormatSpecifier.Number(format: formatter)
]

try! file.write(to: url, config: config)
```

### Tests
There are various test cases implemented to verify compability with a variiety of real world examples of CSV files

## License

MIT license; see [LICENSE](LICENSE.md).
(c) 2020
