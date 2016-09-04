# ArgumentParser

A simple framework for parsing command-line arguments in Swift. Modeled after the Python version. Build and import the framework to use with your `main.swift` file:

```swift
import Cocoa
import ArgumentParser

let parser = ArgumentParser(CommandLine.arguments)
parser.docString = "render to an image file"

let widthOption = IntegerOption(named: "width", required: true, helpString: "output image width", defaultValue: nil)
let heightOption = IntegerOption(named: "height", required: true, helpString: "output image height", defaultValue: nil)
let samplesOption = IntegerOption(named: "samples", flags: "s", "ns", required: true, helpString: "render samples", defaultValue: nil)
let outputOption = StringOption(named: "output", flags: "f", required: false, helpString: "render file output name")
let glossyOption = IntegerOption(named: "--glossy", flag: nil, required: true, helpString: "glossy samples", defaultValue: 50)

if !parser.addOptions(widthOption, heightOption, samplesOption, outputOption, glossyOption) {
    NSLog("Error adding options")
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

### Usage

Create an `ArgumentParser` object. You can create it with the current command-line options, or alternatively with a custom usage string and description.

```swift
// create an ArgumentParser object from command-line arguments
let parser = ArgumentParser(CommandLine.arguments)
```

It is also possible to create the parser with a description and (optional) usage string:


```swift
let parser = ArgumentParser(desc: "render to an image file", usage: nil)
```

#### Help

Formatted help & usage strings are created automatically for you. If you want to create a custom usage string for your parser, pass a string value to the parser when you initialize it.

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

#### Adding Arguments

Arguments are either **positional**, **required** or **optional**. Argument types include **string**, **boolean**, **integer** & **double**.

If you don't pass a value to either the `flag` or `flags` arguments, the option is considered **positional** and must be passed to the parser in the order the user is required to input it.

```swift
let heightOption = IntegerOption(named: "height", helpString: "render output image height", defaultValue: 540)
```
In your command-line application, the `heightOption` above may be referenced by passing an integer value on the command line, or prefacing the value with the `--height` flag.


You don't need to instantiate arguments outside of the parser. Another way to add an integer option for **height** would be by using the `ArgumentParser.addOption` command:

```swift

if let heightOption = parser.addOption(named: "height", 
                                        flag: nil, 
                                        optionType: .integer, 
                                        required: true, 
                                        helpString: nil, 
                                        defaultValue: 540) as? IntegerOption {
                                        
                               
    heightOption.helpString = "render output image height"
}
```

By default, the representation on an option in the `ArgumentParser` usage string is the option name. Changing the `Option.metavar` value will change what is displayed:

```swift
glossyOption.metavar = "glossy samples"
```

```
render <width> <height> -s <samples>  -f <output>  <glossy samples>
```

#### Parsing Values


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




### Todo:

- [ ] multiple values for arguments
- [x] check for conflicting option
- [ ] method to add an argument directly
- [ ] `h` must be a protected flag
- [ ] catch custom errors

### References
- [ArgumentParser: add argument](https://docs.python.org/2.7/library/argparse.html#the-add-argument-method)
- [ArgumentParser: nargs](https://docs.python.org/2.7/library/argparse.html#nargs)

