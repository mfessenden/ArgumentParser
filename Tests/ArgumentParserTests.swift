//
//  ArgumentParserTests.swift
//  ArgumentParserTests
//
//  Created by Michael Fessenden.
//  Copyright © 2018 Michael Fessenden. All rights reserved.
//
//	Web: https://github.com/mfessenden
//	Email: michael.fessenden@gmail.com
//
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
	

import XCTest
@testable import ArgumentParser


class ArgumentParserTests: XCTestCase {

    func testAddOptions() {
        let args: [String] = ["-n", "fred", "--age", "23"]
        
        let parser = ArgumentParser(args)
        parser.docString = "testing parser"
        let nameOption = StringOption(named: "name", required: true, helpString: "person name")
        let ageOption = IntegerOption(named: "age", required: true, helpString: "person age")
        
        
        // add options
        do {
            try parser.addOptions(nameOption, ageOption)
        } catch let error as ParsingError {
            XCTFail(error.description)
        } catch {
            XCTFail("parsing failure.")
        }
        
        // parse
        do {
            let parsedArgs = try parser.parse()
            
            guard let ageValue = parsedArgs["age"] as? Int else {
                XCTFail("error parsing age value.")
                return
            }
            
            guard let nameValue = parsedArgs["name"] as? String else {
                XCTFail("error parsing name value.")
                return
            }
        
            XCTAssert(parser.isValid == true, "parser is invalid.")
            XCTAssert(parser.requiredOptions.count == 2, "error getting required options count.")
            XCTAssert(ageValue == 23, "error parsing integer value: \(ageValue)")
            XCTAssert(nameValue == "fred", "error parsing string value: \(nameValue)")
            
            
        } catch let error as ParsingError {
            XCTFail(error.description)
        } catch {
            XCTFail("parsing failure.")
        }
    }
}
