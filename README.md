![ArgumentParser](images/header-800x128.png)

A simple framework for parsing command-line arguments in Swift. Modeled after the Python version.

[![Swift Version][swift-image]][swift-url]
[![Build Status][travis-image]][travis-url]
[![License][license-image]][license-url]
[![Platforms][platforms-image]][platforms-url]
[![Carthage Compatible][carthage-image]][carthage-url]

## Requirements

- Swift 3.1
- macOS 10.10+
- Xcode 8


## Installation

### Carthage Installation

Create a Cartfile in the root of your project:

    github "mfessenden/ArgumentParser" ~> 1.0

### CocoaPods Installation

Add a reference in your podfile:

    pod 'ArgumentParser', '~> 1.0'


## Usage

Build and import the framework to use with your `main.swift` file, or alternately add the `ArgumentParser.swift` file to your sources.

```swift
// sample main.swift

import Cocoa
import ArgumentParser

let parser = ArgumentParser(CommandLine.arguments)
parser.docString = "render to an image file"

let widthOption = IntegerOption(named: "width", required: true, helpString: "output image width", defaultValue: nil)
let heightOption = IntegerOption(named: "height", required: true, helpString: "output image height", defaultValue: nil)
let samplesOption = IntegerOption(named: "samples", flags: "s", "ns", required: true, helpString: "render samples", defaultValue: nil)
let outputOption = StringOption(named: "output", flags: "f", required: false, helpString: "render file output name")
let glossyOption = IntegerOption(named: "--glossy", flag: nil, required: true, helpString: "glossy samples", defaultValue: 50)

do {
    try parser.addOptions(widthOption, heightOption, samplesOption, outputOption, glossyOption)
} catch let error as ParsingError {
    NSLog(error.description)
    exit(1)
} catch {
    exit(1)
}

func main() -> Int32 {
    do {
        let parsedArgs = try parser.parse()
        if parser.isValid {
            NSLog("success!")
            return 0
        }
    } catch {
        NSLog("parser error")
        return 2
    }
    // general error
    return 1
}

exit(main())
```

### Setup

Create an `ArgumentParser` object with either the current command-line options, or a custom usage string and description:

```swift
// create a parser from command-line arguments
let parser = ArgumentParser(CommandLine.arguments)

// create a parser without command line arguments
let parser = ArgumentParser(desc: "render to an image file", usage: nil)
```

### Help

Formatted help & usage strings are created automatically for you after you've added your options. If you want to create a custom usage string for your parser, pass a string value to the parser when you initialize it.

```
❯ render -h                     
```
```
OVERVIEW:  render to an image file

USAGE:  render <width> <height> -s <samples>  -f <output>  <glossy>

POSITIONAL ARGUMENTS: 

  width                  output image width
  height                 output image height

OPTIONAL ARGUMENTS: 

  -s, -ns, --samples     render samples
  -f, --output           render file output name
  --glossy               glossy samples
```

### Adding Arguments

Arguments are either **positional**, **required** or **optional**. Argument types include **string**, **boolean**, **integer** & **double**.

If you don't pass a value to either the `flag` or `flags` arguments, the option is considered **positional** and must be passed to the parser in the order the user is required to input it.

```swift
let heightOption = IntegerOption(named: "height", helpString: "render output image height", defaultValue: 540)
```
In your command-line application, the `heightOption` above may be referenced by passing an integer value on the command line, or prefacing the value with the `--height` flag.


You don't need to instantiate arguments outside of the parser. Another way to add an integer option for **height** would be by using the `ArgumentParser.addOption` command:

```swift

if let heightOption = try parser.addOption(named: "height", 
                                        flag: nil, 
                                        optionType: .integer, 
                                        required: true, 
                                        helpString: nil, 
                                        defaultValue: 540) as? IntegerOption {
                                        
                               
    heightOption.helpString = "render output image height"
   
} catch error as ParsingError {
    print(error.description)
}
```

By default, the representation on an option in the `ArgumentParser` usage string is the option name. Changing the `Option.metavar` value will change what is displayed:

```swift
glossyOption.metavar = "glossy samples"
```

```
render <width> <height> -s <samples>  -f <output>  <glossy samples>
```

### Parsing Values


To validate the parser and receive its values, call the `ArgumentParser.parse` method:

```swift
do {
    let parsedArgs = try parser.parse()
} catch {
    // deal with error
}
```

If you didn't instantiate your parser with command-line arguments, you can pass them to the `ArgumentParser.parse(_:)` method:

```swift
do {
    let parsedArgs = try parser.parse(CommandLine.arguments)
} catch {
    // deal with error
}
```

[swift-image]:https://img.shields.io/badge/Swift-3.1-brightgreen.svg
[swift-url]: https://swift.org/
[license-image]:https://img.shields.io/badge/License-MIT-blue.svg
[license-url]:https://github.com/mfessenden/ArgumentParser/blob/master/LICENSE
[travis-image]:https://travis-ci.org/mfessenden/ArgumentParser.svg
[travis-url]:https://travis-ci.org/mfessenden/ArgumentParser
[platforms-image]:https://img.shields.io/badge/platforms-macOS-red.svg
[platforms-url]:http://www.apple.com
[carthage-image]:https://img.shields.io/badge/Carthage-compatible-4BC51D.svg
[carthage-url]:https://github.com/Carthage/Carthage
