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
    
   static func colorHash(_ string :String ) -> UIColor {
        var hash : Int = string.hashValue;
        hash = hash>>40;
        
        let hash2: Int = hash&0b000000000000000011111111;
        var hash3: Int = hash&0b000000001111111100000000;
        hash3 = hash3 >> 8;
        var hash4: Int = hash&0b111111110000000000000000;
        hash4 = hash4 >> 16;
        return UIColor(red:CGFloat(Float(hash2)/255) , green:  CGFloat(Float(hash3)/255), blue:  CGFloat(Float(hash4)/255), alpha: 0.8);
        
    }
    
    static func preguntaRandom () -> String {
        let preguntas : [String] = ["Este es un ejemplo de una pregunta corta.",
                                    "Este es el ejemplo de una pregunta de tamaño mediano, por lo tanto va a tener má texto que la pregunta corta.",
                                    "Esta es una pregunta de tamaño aún mayor que las demás y servirá para ver como se ubican las demás cosas con respecto a la altura del TextView.. o UILabel que lo contiene, esperemos que funcionen bien."]
        
        return preguntas.shuffled()[0]
    }
    
    static func palabrasRandom() -> [String] {
        let lista : [String] = ["The", "cake", "is", "a", "lie", "could", "not", "be", "baking", "cookies", "marshmellows","love", "cunt", "time", "red"]
        
        return lista.shuffled().suffix(Int(arc4random_uniform(UInt32(lista.count)))).reversed()
    }
}

