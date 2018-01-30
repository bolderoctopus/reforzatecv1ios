//
//  Materia.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 7/17/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//
//Por hacer: remover la m

import Foundation
import UIKit.UIColor

struct MateriaStruct{
    
    static let HOST: String = "http://172.16.107.1/"
    static let  direccion : String  = HOST + "reforzatec/reforzatec.php?Actividad=1"
    static let DESCARGA_UNIDAD: String = HOST + "/reforzatec/reforzatec.php?Actividad=9&idMaterias="
    static let DESCARGA_DOCUMENTOS_URL: String = HOST + "/reforzatec/documentos/";
    static let COMENTARIOS: String = HOST + "reforzatec/reforzatec.php?Actividad=0&comentario="
    static let CALIFICACIONES: String = HOST + "reforzatec/reforzatec.php?Actividad=10&idUnidad="
    
    let mNombre : String
    let mDescripcion : String?
    var mColor : UIColor
    let id : Int
    let version: Int16
    
    init(id : Int, nombre : String, descripcion : String?, version: Int16) {
        self.id = id
        self.version = version
        self.mNombre = nombre
        if let d = descripcion {
            mDescripcion = d
        }else {
            mDescripcion = ""
        }
        
        mColor = Utils.colorHash(nombre)
    }
    

    static func URL_DIRECTORIO_DOCUMENTOS() ->URL {
         return FileManager().urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    
}
