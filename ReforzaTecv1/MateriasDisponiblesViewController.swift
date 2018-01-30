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
    var dataSource : [MateriaStruct] = []
    let context =  (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var controlActualizar: UIRefreshControl!
    var lastCell : MateriaDescargableCell?// = CustomTableViewCell2 ()
    var tagCeldaExpandida = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurarTabla()
        descargarDisponibles()//y configurar tabla
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
        controlActualizar.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
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
    
    func guardarMateria(_ celda : MateriaDescargableCell){
        celda.estamosDescargando = true
        
        Downloader.bajarContenio(de: celda.objMateria!, con: context, alFinalizar: {
            self.guardarContexto(celdaPorQuitar: celda)
        })
    }
    
    func guardarContexto(celdaPorQuitar celda: MateriaDescargableCell) {
        DispatchQueue.main.async {
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            print("context de coredata guardado" )
            //removiendo de la lista
            self.tableView(self.tableView, commit: .delete, forRowAt: self.tableView.indexPath(for: celda)!)
        }
    }

    func descargarDisponibles() {
        Downloader.descargarListaMaterias(alFinalizar: { lista in
            
            var materiasCD : [Materia]
            do{
                materiasCD = try self.context.fetch(Materia.fetchRequest()) as! [Materia]
            }catch {
                print("Error al tratar de comparar materias descargadas con guardadas")
                return
            }
            var materiasParaMostrar = [MateriaStruct] ()
            var guardar : Bool
            for md in lista {
                guardar = true
                for mg in materiasCD{
                    if(md.key == Int(mg.idMateria)){
                        //no guardar
                        guardar = false
                        break
                    }
                }
                if(guardar){
                    materiasParaMostrar.append(md.value)
                }
            }
            self.dataSource = materiasParaMostrar
        })
    }
    
    //MARK:- Delegados
    func btnDescargarDelegate(_ row : MateriaDescargableCell) {
        guardarMateria(row)
    }
    @objc func refresh(_ controlActualizar: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.descargarDisponibles()
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
