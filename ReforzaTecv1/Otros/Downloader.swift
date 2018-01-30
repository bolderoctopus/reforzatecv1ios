//
//  Downloader.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 12/28/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import Foundation
import CoreData

class Downloader {
    /**
     Descarga un archivo y lo guarda donde se le especifique.
     */
    class func bajar(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request =  URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if  error == nil {
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl!, to: localUrl)                    
                    completion()
                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                }
            } else {
                print("Failure: %@", error!.localizedDescription);
            }
        }
        task.resume()
    }
    
    /**
     Descarga la lista de materias disponibles.
     */
    class func descargarListaMaterias ( alFinalizar: @escaping ([Int32: MateriaStruct])-> ()) {
        var lista = [Int32: MateriaStruct] ()
        let url = URL(string: MateriaStruct.ESQUEMA)
        let session = URLSession.shared
        
        let task = session.dataTask(with: url!, completionHandler: {data,response,error -> Void in
            lista.removeAll()
            if(error != nil){
                print(error.debugDescription)
            }
            else {
                var nombres = [String] ()
                var ids = [String] ()
                var descripciones = [String] ()
                var versiones = [String]()
                do {
                    if NSString(data: data!, encoding: String.Encoding.utf8.rawValue) != nil {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [AnyObject]
                        nombres = json.map { ($0 as! [String:AnyObject]) ["nombre"] as! String }
                        ids = json.map { ($0 as! [String:AnyObject]) ["idMaterias"] as! String }
                        descripciones = json.map { ($0 as! [String:AnyObject]) ["descripcion"] as! String }
                        versiones = json.map{($0 as! [String:AnyObject]) ["version"] as! String}
                    }
                } catch {
                    print(error)
                }
        
                guard nombres.count == ids.count && ids.count == descripciones.count else {
                    return
                }
                
                if(ids.count > 0){
                    for i in 0...(ids.count-1){
                        let id = Int32(ids[i])!
                        let m = MateriaStruct(id: Int(id), nombre: nombres[i], descripcion: descripciones[i], version: Int16(versiones[i])!)
                        lista[id] = m
                    }
                }
                alFinalizar(lista)
            }
        })
        task.resume()
        
    }

        /**
         Descarga las unidades, ejercicios y archivos de una materia.
         */
    class func bajarContenio(de materia: MateriaStruct, con context: NSManagedObjectContext, alFinalizar: @escaping ()->()){

        let url = URL(string: MateriaStruct.DESCARGA_UNIDAD + String(materia.Id))
        let session = URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: {data, response, error -> Void in
            if(error != nil){
                print(error.debugDescription)
            }
            else {
                var archivosPorDescargar: [String] = []
                
                let coreDataMateria = Materia(context: context)
                coreDataMateria.idMateria = Int32(materia.Id)
                coreDataMateria.nombre = materia.Nombre
                coreDataMateria.descripcion = materia.Descripcion
                coreDataMateria.version = materia.Version
                
                let arregloRaiz = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let unidadesJson = arregloRaiz as? [Any]{
                    for unidadJson in unidadesJson{
                        if let unidad = unidadJson as? [String: Any]{
                            let coreDataUnidad = Unidad(context: context)
                            
                            if let id = unidad["id"] as? String{
                                coreDataUnidad.idUni = Int16(id)!
                            }
                            if let nombre = unidad["nombre"] as? String{
                                coreDataUnidad.nombreUni = nombre
                            }
                            if let descripcion = unidad["descripcion"] as? String {
                                coreDataUnidad.descripcionUni = descripcion
                            }
                            if let teoria = unidad["teoria"] as? String{
                                coreDataUnidad.teoria = teoria
                                archivosPorDescargar.append(teoria)
                            }
                            if let ejemplo = unidad["ejemplo"] as? String{
                                coreDataUnidad.ejemplo = ejemplo
                                archivosPorDescargar.append(ejemplo)
                            }
                            
                            if let ejerciciosJson = unidad["ejercicios"] as? [Any]{
                                for ejercicioJson in ejerciciosJson{
                                    if let ejercicio = ejercicioJson as? [String: Any]{
                                        let coreDataEjercicio = Ejercicio(context: context)
                                        if let pregunta = ejercicio["pregunta"] as? String{
                                            coreDataEjercicio.textos = pregunta
                                        }
                                        if let respuestas = ejercicio["respuestas"] as? String{
                                            coreDataEjercicio.respuestas = respuestas
                                        }
                                        if let tipo = ejercicio["tipo"] as? String{
                                            coreDataEjercicio.tipo = tipo
                                        }
                                        coreDataEjercicio.unidad = coreDataUnidad
                                        coreDataUnidad.addToEjercicios(coreDataEjercicio)
                                    }
                                }
                            }
                            if let evaluacionesJson = unidad["evaluacion"] as? [Any]{
                                for evaluacionJson in evaluacionesJson{
                                    if let evaluacion = evaluacionJson as? [String: Any]{
                                        let coreDataEvaluacion = Evaluacion(context: context)
                                        
                                        if let idEv = evaluacion["idEvaluaciones"] as? String{
                                            coreDataEvaluacion.idEv = Int16(idEv)!
                                        }
                                        if let texto = evaluacion["textos"] as? String{
                                            coreDataEvaluacion.pregunta = texto
                                        }
                                        if let respuesta = evaluacion["respuestas"] as?     String {
                                            coreDataEvaluacion.respuestas = respuesta
                                        }
                                        if let puntaje = evaluacion["puntos"] as? Int16 {
                                            coreDataEvaluacion.puntos = puntaje
                                        }
                                        coreDataUnidad.addToEvaluaciones(coreDataEvaluacion)
                                    }
                                }
                            }
                            coreDataUnidad.materia = coreDataMateria
                            coreDataMateria.addToUnidades(coreDataUnidad)
                        }
                    }
                }
                if archivosPorDescargar.isEmpty{
                    alFinalizar()
                }else{
                    self.descargarArchivos(archivos: archivosPorDescargar, alFinalizar: alFinalizar)
                }
            }
            
        })
        task.resume()
    }
    /**
     Similar a bajarContenido, pero más bien reemplaza lo que hay en una materia ya existente.
     */
    class func actualizar(materia: Materia, con context: NSManagedObjectContext, alFinalizar: @escaping ()-> Void) {
        let url = URL(string: MateriaStruct.DESCARGA_UNIDAD + String(materia.idMateria))
        let session = URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: {data, response, error -> Void in
            if(error != nil){
                print(error.debugDescription)
                print("Error al descargar la lista de materias")
            }
            else {
                var archivosPorDescargar: [String] = []
                let arregloRaiz = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let unidadesJson = arregloRaiz as? [Any]{
                    for unidadJson in unidadesJson{
                        if let unidad = unidadJson as? [String: Any]{
                            let coreDataUnidad = Unidad(context: context)
                            
                            if let id = unidad["id"] as? String{
                                coreDataUnidad.idUni = Int16(id)!
                            }
                            if let nombre = unidad["nombre"] as? String{
                                coreDataUnidad.nombreUni = nombre
                            }
                            if let descripcion = unidad["descripcion"] as? String {
                                coreDataUnidad.descripcionUni = descripcion
                            }
                            if let teoria = unidad["teoria"] as? String{
                                coreDataUnidad.teoria = teoria
                                archivosPorDescargar.append(teoria)
                            }
                            if let ejemplo = unidad["ejemplo"] as? String{
                                coreDataUnidad.ejemplo = ejemplo
                                archivosPorDescargar.append(ejemplo)
                            }
                            if let ejerciciosJson = unidad["ejercicios"] as? [Any]{
                                for ejercicioJson in ejerciciosJson{
                                    if let ejercicio = ejercicioJson as? [String: Any]{
                                        let coreDataEjercicio = Ejercicio(context: context)
                                        if let pregunta = ejercicio["pregunta"] as? String{
                                            coreDataEjercicio.textos = pregunta
                                        }
                                        if let respuestas = ejercicio["respuestas"] as? String{
                                            coreDataEjercicio.respuestas = respuestas
                                        }
                                        if let tipo = ejercicio["tipo"] as? String{
                                            coreDataEjercicio.tipo = tipo
                                        }
                                        coreDataEjercicio.unidad = coreDataUnidad
                                        coreDataUnidad.addToEjercicios(coreDataEjercicio)
                                    }
                                }
                            }
                            if let evaluacionesJson = unidad["evaluacion"] as? [Any]{
                                for evaluacionJson in evaluacionesJson{
                                    if let evaluacion = evaluacionJson as? [String: Any]{
                                        let coreDataEvaluacion = Evaluacion(context: context)
                                        
                                        if let idEv = evaluacion["idEvaluaciones"] as? String{
                                            coreDataEvaluacion.idEv = Int16(idEv)!
                                        }
                                        if let texto = evaluacion["textos"] as? String{
                                            coreDataEvaluacion.pregunta = texto
                                        }
                                        if let respuesta = evaluacion["respuestas"] as?     String {
                                            coreDataEvaluacion.respuestas = respuesta
                                        }
                                        if let puntaje = evaluacion["puntos"] as? Int16 {
                                            coreDataEvaluacion.puntos = puntaje
                                        }
                                        coreDataUnidad.addToEvaluaciones(coreDataEvaluacion)
                                    }
                                }
                            }
                            coreDataUnidad.materia = materia
                            materia.addToUnidades(coreDataUnidad)
                        }
                    }
                }
                if archivosPorDescargar.isEmpty{
                    alFinalizar()
                }else{
                    self.descargarArchivos(archivos: archivosPorDescargar, alFinalizar: alFinalizar)
                }
            }
            
        })
        task.resume()
    }
        
    /**
     Permite descargar más de un archivo se forma secuencial y se asegura de ejecutar el bloque de código alFinalizar una vez
         hallan acabado de descargarse todos los archivos.
     */
    class func descargarArchivos( archivos: [String], alFinalizar: @escaping ()->() ){
        var archivos = archivos
        if archivos.count == 1 { // caso de parada
            let urlLocal = MateriaStruct.URL_DIRECTORIO_DOCUMENTOS().appendingPathComponent(archivos[0])
            Downloader.bajar(url: URL(string: MateriaStruct.DESCARGA_DOCUMENTOS_URL + archivos[0])! , to: urlLocal, completion: alFinalizar)
        }else {// caso recursivo
            let archivo = archivos.removeFirst()
            let urlLocal = MateriaStruct.URL_DIRECTORIO_DOCUMENTOS().appendingPathComponent(archivo)
            let siguienteDescarga = {
                self.descargarArchivos(archivos: archivos, alFinalizar: alFinalizar)
            }
            Downloader.bajar(url: URL(string: MateriaStruct.DESCARGA_DOCUMENTOS_URL + archivo)! , to: urlLocal, completion: siguienteDescarga)
        }
    }
    
}
