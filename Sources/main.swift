//
//  main.swift
//  ArgumentParser
//
//  Created by Michael Fessenden on 8/22/16.
//  Copyright © 2016 Michael Fessenden. All rights reserved.
//

import Foundation

#if DEBUG
dump(CommandLine.arguments)
#endif


let parser = ArgumentParser(CommandLine.arguments)
parser.docString = "render the current scene"

let wo = IntegerOption(named: "width", required: true, helpString: "output image width", defaultValue: nil)
let ho = IntegerOption(named: "height", required: true, helpString: "output image height", defaultValue: 200)
let so = IntegerOption(named: "samples", flags: "s", "ns", required: true, helpString: "render samples", defaultValue: nil)
let fo = StringOption(named: "output", flags: "f", required: false, helpString: "render file output name")
let go = IntegerOption(named: "--glossy", flag: nil, required: true, helpString: "glossy samples", defaultValue: 50)
go.metavar = "glossy samples"

parser.addOptions(wo, ho, so, fo, go)



// 0 - success
// 1 - general error
// 2 - command-line usage error
func main() -> Int32 {
    do {
        try parser.parse()
        if parser.isValid {
            print("# Parsing succeeded.")
            return 0
        }
    } catch {
        print("# Something went wrong.")
        return 1
    }
    print("# Something went wrong.")
    return 1
}




exit(main())

