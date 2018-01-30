//
//  Libreria.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 7/17/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import Foundation
import UIKit

class Utils :  NSObject {
    /**
     Regresa un color de acuerdo al Hash de una String.
     */
    static func colorHash(_ string :String ) -> UIColor {
        var hash : UInt64 = strHash(string)
        hash = hash>>40
        let hash2: Int = Int(hash&0b000000000000000011111111)
        var hash3: Int = Int(hash&0b000000001111111100000000)
        hash3 = hash3 >> 8
        var hash4: Int = Int(hash&0b111111110000000000000000)
        hash4 = hash4 >> 16
        return UIColor(red:CGFloat(Float(hash2)/255) , green:  CGFloat(Float(hash3)/255), blue:  CGFloat(Float(hash4)/255), alpha: 0.8)
    }
    /**
     Utilizado para reemplazar al hash con el que cuentan los String debido a que ese puede cambiar de un ejecución a otra, mientras que este
     debería devolver el mismo resultado según la cadena dada ya sea en simulador o en diferentes dispositivos.
     */
    static  func strHash(_ str: String) -> UInt64 {
        var result = UInt64(5368911902)
        let buf = [UInt8](str.utf8)
        for b in buf {
            result = 127 * (result & 0x00ffffffffffffff) + UInt64(b)
        }
        return result
    }
}

