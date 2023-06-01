//
//  String.swift
//  Aftermint
//
//  Created by Platfarm on 2023/05/30.
//

import Foundation

extension String {
    
    func convertToDecimal() -> Int? {
        let stringToConvert = self.dropFirst(2)
        let decimalNumber = Int(stringToConvert, radix: 16)
        return decimalNumber
    }
    
    func convertToHex() -> String? {
        guard let convertedInt = Int(self) else {
            return nil
        }
        let hex = String(convertedInt, radix: 16)
        return "0x" + hex
    }
    
}
