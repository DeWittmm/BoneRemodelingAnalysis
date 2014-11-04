//
//  HelperFunctions.swift
//  BoneFatigueAnalysis
//
//  Created by Michael DeWitt on 10/28/14.
//  Copyright (c) 2014 Michael DeWitt. All rights reserved.
//

import Foundation

//MARK: Input

func cmdInput(index: Int) -> Int? {
    if let arg = String.fromCString(C_ARGV[index]) {
        return arg.toInt()
    }
    return .None
}

func input() -> String {
    var keyboard = NSFileHandle.fileHandleWithStandardInput()
    var inputData = keyboard.availableData
    return NSString(data: inputData, encoding:NSUTF8StringEncoding)!
}

func input() -> Int? {
    let keyboard = NSFileHandle.fileHandleWithStandardInput()
    let inputData = keyboard.availableData
    
    if let str: String = NSString(data: inputData, encoding:NSUTF8StringEncoding) {
        return str.toInt()
    }
    
    return .None
}

//MARK: Arithmetic Helpers

func sum(value: [Double], range: Range<Int>) -> Double {
    var sum:Double = 0;
    for i in range {
        sum += value[i]
    }
    return sum
}

func formattedDescription(values: [Double]) -> String {
    var description = ""
    for i in values {
        description += "\(i)\r"
    }
    return description
}

//MARK: File Helpers

func writeValueAsCSV(value: String, toFilePath filePath: String) {
    let dirs : [String]? = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String]
    
    if let dirs = dirs {
        let dir = dirs.first! //documents directory
        let filePathType = filePath + ".csv"
        let path = dir.stringByAppendingPathComponent(filePathType);
        
        //writing
        value.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding, error: nil);
        
        //reading
//        let text2 = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)
    }
}

func plot(values: [Double]) {
    let task = NSTask()
    task.launchPath = "/bin/echo"
    task.arguments = ["first-argument", "second-argument"]

    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()
}
 