//
//  CSVFileReader.swift
//  GuestLogixChallenge
//
//  Created by Mark Volpe on 2019-05-08.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import UIKit

class CSVFileReader {
    public func parseFileData(fileName:String, fileType:String)->[[String]]?{
        guard let stringData = getFileData(fileName: fileName, fileType: fileType) else{
            return nil
        }
        
        let rows = stringData.components(separatedBy: "\n")
        let rowDict = rows.map({$0.components(separatedBy: ",")})
        return rowDict
    }
    
    private func getFileData(fileName:String, fileType:String)->String?{
        guard fileName.isEmpty == false else{
            return nil
        }
        
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: fileType) else {
            return nil
        }
        
        do {
            var contents = try String(contentsOfFile: filePath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filePath)")
            return nil
        }
    }
    
    private func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
}
