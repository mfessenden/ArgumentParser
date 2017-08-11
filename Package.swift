//
//  Package.swift
//  ArgumentParser
//
//  Created by Michael Fessenden on 8/22/16.
//  Copyright © 2016 Michael Fessenden. All rights reserved.
//
// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "ArgumentParser",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ArgumentParser",
            targets: ["ArgumentParser"]),
        ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ArgumentParser",
            dependencies: []),
        .testTarget(
            name: "ArgumentParserTests",
            dependencies: ["ArgumentParser"]),
        ]
)

