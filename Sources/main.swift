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

let fn = StringOption(named: "filename", flag: "f", required: true, helpString: "output file name", defaultValue: "temp")
let wo = IntegerOption(named: "width", flag: "w", required: false, helpString: "output width", defaultValue: 960)
let ho = IntegerOption(named: "height", flag: "h", required: true, helpString: "output height", defaultValue: 540)
let sm = IntegerOption(named: "samples", flags: "s", "ns", required: true, helpString: "render samples", defaultValue: 10)
let db = BoolOption(named: "debug")


parser.addOptions(wo, ho, sm, fn, db)
parser.help()