//
//  main.swift
//  ArgumentParser
//
//  Created by Michael Fessenden on 8/22/16.
//  Copyright © 2016 Michael Fessenden. All rights reserved.
//

import Foundation
import ArgumentParser


let parser = ArgumentParser(CommandLine.arguments)
parser.docString = "render to an image file"


let widthOption = IntegerOption(named: "width", required: true, helpString: "output image width", defaultValue: nil)
let heightOption = IntegerOption(named: "height", required: true, helpString: "output image height", defaultValue: nil)
let samplesOption = IntegerOption(named: "samples", flags: "s", "ns", required: true, helpString: "render samples", defaultValue: nil)
let outputOption = StringOption(named: "output", flags: "f", required: false, helpString: "render file output name")
let glossyOption = IntegerOption(named: "--glossy", flag: nil, required: true, helpString: nil, defaultValue: 50)
glossyOption.metavar = "glossy samples"
glossyOption.helpString = "glossy samples"


if !parser.addOptions(widthOption, heightOption, samplesOption, outputOption, glossyOption) {
    NSLog("Error adding options")
    exit(1)
}



// 0 - success
// 1 - general error
// 2 - command-line usage error
func main() -> Int32 {
    do {
        let parsedArgs = try parser.parse()
        if parser.isValid {
            print(parsedArgs)
            return 0
        }
    } catch let error as ParsingError {
        print(error.description)
        return 2
        
    } catch {
        print("general error")
        return 2
    }

    print("  " + parser.usageString + "\n")
    for option in parser.invalidOptions {
        print("   \(option.description)")
    }
    return 1
}


exit(main())

