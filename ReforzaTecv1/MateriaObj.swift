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

// cambiar a una struct
class MateriaObj: NSObject {
    
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
    
    init(id : Int, nombre : String, descripcion : String?) {
        self.id = id
        mNombre = nombre
        if let d = descripcion {
            mDescripcion = d
        }else {
            mDescripcion = ""
        }
        
        mColor = Utils.colorHash(nombre)
    }
    
    
    
    
    class func  llenarConEjemplos () -> [MateriaObj] {
        var materiasDescargadas : [MateriaObj] = []
        
        materiasDescargadas.append(MateriaObj(id:0, nombre: "Ciencias", descripcion: "Aqui podras apredner los secretos de la lengua espanola asi como inglesa. lengua espanola asi como inglesa.lengua espanola asi como inglesa.lengua espanola asi como inglesa.lengua espanola asi como inglesa.vargua espanola asi como inglesa.lengua espanola asi como inglesa.lengua espanola asi como inglesa.lengua espanola asi como inglesa. lengua espanola asi como inglesa."))
        materiasDescargadas.append(MateriaObj(id:1, nombre: "Espanol", descripcion: "Aqui podras apredner los secretos de la lengua espanola asi como inglesa."))
        materiasDescargadas.append(MateriaObj(id:2, nombre: "Educasion inglesa", descripcion: "Por que existe esta materia?!?!"))
        materiasDescargadas.append(MateriaObj(id:3, nombre: "Vuelo", descripcion: nil))
        materiasDescargadas.reverse()
        
        return materiasDescargadas
    }
    
    class func ejemplos () {
        var materiasDescargadas : [MateriaObj] = []/*
        materiasDescargadas.append(MateriaObj(nombre: "Matematicas", descripcion: "Aqui podras apredner los secretos de la lengua espanola asi como inglesa."))
        materiasDescargadas.append(MateriaObj(nombre: "Redes", descripcion: "Por que existe esta materia?!?!"))
        materiasDescargadas.append(MateriaObj(nombre: "Defensa Personal", descripcion: nil))
        materiasDescargadas.append(MateriaObj(nombre: "Fisica ll", descripcion: "Todo lo que puedas esperar de la fisica."))
        materiasDescargadas.append(MateriaObj(nombre: "Conjuros 1", descripcion: "Aprende a realizar conjuros y encantamientos de todo nivel. Busquen sus nuevos libros en la biblioteca por favor!"))
        materiasDescargadas.append(MateriaObj(nombre:"Lorem Ipsum", descripcion : "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."))*/
        return    materiasDescargadas.reverse()
        
    }

    class func URL_DIRECTORIO_DOCUMENTOS() ->URL {
         return FileManager().urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    
}
