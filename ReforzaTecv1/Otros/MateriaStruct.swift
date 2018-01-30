//
//  Materia.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 7/17/17.
//  Copyright © 2017 TecUruapan. All rights reserved.

import Foundation
import UIKit.UIColor

/**
 Modelo de la información de una materia previo a almacenarse en CoreData
 */
struct MateriaStruct{
    
    static let HOST: String = "http://172.16.107.1/"
    static let ESQUEMA : String  = HOST + "reforzatec/reforzatec.php?Actividad=1"
    static let DESCARGA_UNIDAD: String = HOST + "/reforzatec/reforzatec.php?Actividad=9&idMaterias="
    static let DESCARGA_DOCUMENTOS_URL: String = HOST + "/reforzatec/documentos/";
    static let COMENTARIOS: String = HOST + "reforzatec/reforzatec.php?Actividad=0&comentario="
    static let CALIFICACIONES: String = HOST + "reforzatec/reforzatec.php?Actividad=10&idUnidad="
    
    let Nombre : String
    let Descripcion : String?
    let Id : Int
    let Version: Int16
    
    var color : UIColor
    
    init(id : Int, nombre : String, descripcion : String?, version: Int16) {
        self.Id = id
        self.Version = version
        self.Nombre = nombre
        if let d = descripcion {
            Descripcion = d
        }else {
            Descripcion = ""
        }
        color = Utils.colorHash(nombre)
    }

    static func URL_DIRECTORIO_DOCUMENTOS() ->URL {
         return FileManager().urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    
}
