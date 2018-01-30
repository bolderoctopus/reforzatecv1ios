//
//  SeccionUnidad.swift
//  ReforzaTecv1
//
//  Created by Delfin: Verano Científico on 26/07/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import Foundation

/**
 Modelo de lo que es una unidad al mostrarla en ContenidoMateria
 */
struct UnidadStruct {
    var nombre: String?
    var descripcion: String?
    var numero: Int
    var expanded: Bool = false
    var contenido: [String] = []
    
    init(nombre: String?, descripcion: String?, numero: Int) {
        self.nombre = nombre
        self.descripcion = descripcion
        self.numero = numero
    }
    
}

