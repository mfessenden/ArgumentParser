# ArgumentParser

A simple framework for parsing command-line arguments in Swift. Modeled after the Python version.

### Usage

Arguments are either:

- Positional
- Optional

Positional arguments are required.

```swift
// create an ArgumentParser object
let parser = ArgumentParser(CommandLine.arguments)

// add a positional arguments
parser.addOption("width", required: true, helpString: "output image width", defaultValue: nil)

parser.addOption("height", required: true, helpString: "output image height", defaultValue: nil)

// parse the arguments
parser.parse()

// print help
parser.help()
```


### References
- [ArgumentParser: add argument](https://docs.python.org/2.7/library/argparse.html#the-add-argument-method)
- [ArgumentParser: nargs](https://docs.python.org/2.7/library/argparse.html#nargs)

