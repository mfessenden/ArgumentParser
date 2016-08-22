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


func main(_ args: [String]) -> Int32 {
    for arg in args {
        print(" -> \(arg)")
    }
    return 0
}


exit(main(CommandLine.arguments))
