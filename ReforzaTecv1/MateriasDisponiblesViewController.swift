
//
//  MateriasDisponiblesViewController.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 7/17/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit
//Renombrar a materiasDescargables?
class MateriasDisponiblesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BtnMateriaDelegate {

    @IBOutlet weak var tableView: UITableView!
    var dataSource : [MateriaObj] = []
    let context =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var controlActualizar: UIRefreshControl!
    var lastCell : MateriaDescargableCell?// = CustomTableViewCell2 ()
    var tagCeldaExpandida = -1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurarTabla()
        descargarListaMaterias()//y configurar tabla
      
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // soluciona un detalle que, luego de cargar la vista tenias que darle un click para que saliera la lista
        if(dataSource.isEmpty){
            mostrarVistaVacia(true)
        }else{
            tableView.reloadData()
        }
    }
    
    
    @IBAction func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            var touchPoint = sender.location(in: self.view)
            touchPoint.y -= 70
            //seria mejor restarle la altura de la barra de navegacion + barra de estado?
            if let rowIndex = tableView.indexPathForRow(at: touchPoint) {
                expandirCelda(numero: rowIndex.row)
            }
        }
    }
    
//    MARK:- Cositas TableView
    
    func configurarTabla() {
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName : "MateriaDescargableCell", bundle : nil) ,forCellReuseIdentifier: "MateriaDescargableCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        // aniade la cosa para recargar cuando deslizes hacia abajo
        controlActualizar = UIRefreshControl()
        controlActualizar.addTarget(self, action: #selector(actualizar(_:)), for: .valueChanged)
        controlActualizar.tintColor = UIColor.orange
        tableView.addSubview(controlActualizar)
        // le pone un mensaje a mostrar si esta vacia
        let emptyView = (UINib(nibName: "MateriasDisponiblesEmptyView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView)
        tableView.separatorStyle  = UITableViewCellSeparatorStyle.none
        tableView.backgroundView = emptyView
        tableView.backgroundView?.isHidden = true
    }
    
    // Le pone un mensaje a la table view diciendo que no se pudo recargar
    func mostrarVistaVacia(_ mostrar: Bool) {
        tableView.backgroundView?.isHidden = !mostrar
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guardarMateria(tableView.cellForRow(at: indexPath) as! MateriaDescargableCell)
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MateriaDescargableCell", for: indexPath) as! MateriaDescargableCell
        let m = dataSource[indexPath.row]
        cell.nombreLabel.text = m.mNombre
        cell.descripcionTextView.text = m.mDescripcion
        cell.cellExists = true
        cell.detailsView.backgroundColor = Utils.colorHash(m.mNombre)
        cell.titleView.backgroundColor = Utils.colorHash(m.mNombre)
        cell.objMateria = m
        cell.delegate = self
        cell.VersionLabel.text = NSLocalizedString("version", comment: "") + ": \(m.version)"
        UIView.animate(withDuration: 0) {
            cell.contentView.layoutIfNeeded()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete){
            dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
        }
    }
   
    
    
    //MARK:- Mis metodos extras
    
    func expandirCelda(numero : Int) {
        self.tableView.beginUpdates()
        
        let previousCellTag = tagCeldaExpandida
        
        if lastCell != nil{
            if lastCell!.cellExists {
                self.lastCell!.animate(duration: 0.2, c: {
                    self.view.layoutIfNeeded()
                })
                if numero == tagCeldaExpandida {
                    tagCeldaExpandida = -1
                    lastCell = nil//CustomTableViewCell2()
                }
            }
        }
        
        if numero != previousCellTag {
            tagCeldaExpandida = numero
            lastCell = (tableView.cellForRow(at: IndexPath(row: tagCeldaExpandida, section: 0)) as! MateriaDescargableCell)
            self.lastCell!.animate(duration: 0.2, c: {
                self.view.layoutIfNeeded()
            })
        }
        
        self.tableView.endUpdates()
    }
    
    func guardarMateria(_ row : MateriaDescargableCell){
        row.indicarDescarga()
        //guardando en CoreData
        let objMateria = row.objMateria!

        let url = URL(string: MateriaObj.DESCARGA_UNIDAD + String(objMateria.id))
//        print(url!.absoluteString)
        let session = URLSession.shared
        let task = session.dataTask(with: url!, completionHandler: {data, response, error -> Void in
            if(error != nil){
                print(error.debugDescription)
                print("Error al descargar la lista de materias")
            }
            else {
                var archivosPorDescargar: [String] = []
                // una materia
                let coreDataMateria = Materia(context:self.context)
                coreDataMateria.idMateria = Int32(objMateria.id)
                coreDataMateria.nombre = objMateria.mNombre
                coreDataMateria.descripcion = objMateria.mDescripcion
                coreDataMateria.version = objMateria.version
                

                let arregloRaiz = try? JSONSerialization.jsonObject(with: data!, options: [])
                if let unidadesJson = arregloRaiz as? [Any]{
                    for unidadJson in unidadesJson{
                        if let unidad = unidadJson as? [String: Any]{
                            let coreDataUnidad = Unidad(context: self.context)
                            
                            if let id = unidad["id"] as? String{
                                coreDataUnidad.idUni = Int16(id)!
                            }
                          
                            if let nombre = unidad["nombre"] as? String{
//                                print("nombre: \(nombre)")
                                coreDataUnidad.nombreUni = nombre
                            }
                            if let descripcion = unidad["descripcion"] as? String {
//                                print("descripcion: \(descripcion)")
                                coreDataUnidad.descripcionUni = descripcion
                            }
                            
                            if let teoria = unidad["teoria"] as? String{
                                //print("teoria: \(teoria)")
                                coreDataUnidad.teoria = teoria
                                archivosPorDescargar.append(teoria)
                            }
                            
                            if let ejemplo = unidad["ejemplo"] as? String{
                                //print("ejemplo: \(ejemplo)")
                                coreDataUnidad.ejemplo = ejemplo
                                archivosPorDescargar.append(ejemplo)
                            }
                            
                            if let ejerciciosJson = unidad["ejercicios"] as? [Any]{
                                for ejercicioJson in ejerciciosJson{
                                    if let ejercicio = ejercicioJson as? [String: Any]{
                                        let coreDataEjercicio = Ejercicio(context: self.context)
                                        if let pregunta = ejercicio["pregunta"] as? String{
//                                            print("pregunta \(pregunta)")
                                            coreDataEjercicio.textos = pregunta
                                        }
                                        if let respuestas = ejercicio["respuestas"] as? String{
//                                            print("respuestas \(respuestas)")
                                            coreDataEjercicio.respuestas = respuestas
                                        }
                                        if let tipo = ejercicio["tipo"] as? String{
//                                            print("tipo \(tipo)")
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
                                        let coreDataEvaluacion = Evaluacion(context: self.context)
                                        
                                        if let idEv = evaluacion["idEvaluaciones"] as? String{
                                            coreDataEvaluacion.idEv = Int16(idEv)!
                                        }

                                        if let texto = evaluacion["textos"] as? String{
                                            //print("texto \(texto)")
                                            coreDataEvaluacion.pregunta = texto
                                        }
                                        if let respuesta = evaluacion["respuestas"] as? 	String {
                                            //print("respuesta \(respuesta)")
                                            coreDataEvaluacion.respuestas = respuesta
                                        }
                                        if let puntaje = evaluacion["puntos"] as? Int16 {
                                            //print("puntaje \(puntaje)")
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
                    self.guardarContexto(celdaPorQuitar: row)
                }else{
                    self.descargarArchivos(archivos: archivosPorDescargar, celdaPorQuitar: row)
                }
            }

        })
        task.resume()
    }
    
    func descargarArchivos( archivos: [String], celdaPorQuitar celda: MateriaDescargableCell){
        
        var archivos = archivos
        if archivos.count == 1 { // caso de parada
            let alFinalizarDescargas = {
                self.guardarContexto(celdaPorQuitar: celda)
            }
            let urlLocal = MateriaObj.URL_DIRECTORIO_DOCUMENTOS().appendingPathComponent(archivos[0])
            Downloader.load(url: URL(string: MateriaObj.DESCARGA_DOCUMENTOS_URL + archivos[0])! , to: urlLocal, completion: alFinalizarDescargas)
        }else {// caso recursivo
            let archivo = archivos.removeFirst()
            let urlLocal = MateriaObj.URL_DIRECTORIO_DOCUMENTOS().appendingPathComponent(archivo)
            let siguienteDescarga = {
                self.descargarArchivos(archivos: archivos, celdaPorQuitar: celda)
            }
            Downloader.load(url: URL(string: MateriaObj.DESCARGA_DOCUMENTOS_URL + archivo)! , to: urlLocal, completion: siguienteDescarga)
        }
    }
    
    func guardarContexto(celdaPorQuitar celda: MateriaDescargableCell) {
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            print("context de coredata guardado" )
            //removiendo de la lista
            self.tableView(self.tableView, commit: .delete, forRowAt: self.tableView.indexPath(for: celda)!)
        }
    }
    

    func descargarListaMaterias () {
        let url = URL(string: MateriaObj.direccion)
        let session = URLSession.shared
        
        let task = session.dataTask(with: url!, completionHandler: {data,response,error -> Void in
            self.dataSource.removeAll()
            //task ejecutandose
            if(error != nil){
                print(error.debugDescription)
                print("Error al descargar la lista de materias")            }
            else {
                self.parsearJSON(d: data!)
            }
        })
        task.resume()
     
    }
    
  //parsea json e inicializa la tabla
    func parsearJSON(d: Data) {
        var nombres = [String] ()
        var ids = [String] ()
        var descripciones = [String] ()
        var versiones = [String]()
        do {
            if NSString(data: d, encoding: String.Encoding.utf8.rawValue) != nil {
                let json = try JSONSerialization.jsonObject(with: d, options: .mutableContainers) as! [AnyObject]
                // ???
                nombres = json.map { ($0 as! [String:AnyObject]) ["nombre"] as! String }
                ids = json.map { ($0 as! [String:AnyObject]) ["idMaterias"] as! String }
                descripciones = json.map { ($0 as! [String:AnyObject]) ["descripcion"] as! String }
                versiones = json.map{($0 as! [String:AnyObject]) ["version"] as! String}
            }
        } catch {
            print(error)
        }
        //tal vez es inecesario, por quitar?
        guard nombres.count == ids.count && ids.count == descripciones.count else {
            print("Tenemos diferente cantidad de materias, ids o descripciones")
            return
        }
        
        //agarrar las materias ya guardadas para no mostrarlas
        var materiasGuardadas : [Materia]
        do{
            materiasGuardadas = try context.fetch(Materia.fetchRequest()) as! [Materia]
        }catch {
            print("Error al tratar de comparar materias descargadas con guardadas")
            return
        }
        if(ids.count > 0){
        for i in 0...(ids.count-1){
            dataSource.append(MateriaObj(id: Int(ids[i])!, nombre: nombres[i], descripcion: descripciones[i], version: Int16(versiones[i])!))
        }
        }
        
        var materiasParaMostrar = [MateriaObj] ()
        var guardar : Bool
        for md in dataSource {
            guardar = true
            for mg in materiasGuardadas{
                if(md.id == Int(mg.idMateria)){
                    //no guardar
                    guardar = false
                    break
                }
            }
            if(guardar){
                materiasParaMostrar.append(md)
            }
        }
        //por renombrar y removar cosas inesecarias
        dataSource = materiasParaMostrar
        //configurarTabla()
        
    }
    
    //MARK:- Delegados
    func btnDescargarDelegate(_ row : MateriaDescargableCell) {
        guardarMateria(row)
    }
    @objc func actualizar(_ controlActualizar: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.descargarListaMaterias()
            self.tableView.reloadData()
            self.controlActualizar.endRefreshing()
            if(self.dataSource.isEmpty){
                self.mostrarVistaVacia(true)
            }else{
                self.tableView.reloadData()
                self.mostrarVistaVacia(false)
            }
        })
        
        
        
    }
   

}
