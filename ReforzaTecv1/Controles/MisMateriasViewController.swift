			//
//  ViewController.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 7/17/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit
import CoreData

class MisMateriasViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BtnBorrarMateriaDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let color : UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    let Context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var MateriasCoreData : [Materia] = []
    var ultimaCeldaExpandida : MateriaCell?
    var tagCeldaExpandida = -1
    var controlActualizar: UIRefreshControl!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = color
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : color]
        
        recuperarData()
        tableView.reloadData()
        mostrarEmptyView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configurarTabla()
        let botonInfo = UIButton.init(type: .infoLight)
        botonInfo.addTarget(self, action: #selector(mostrarInfo), for: .touchUpInside)
        let barButton = UIBarButtonItem.init(customView: botonInfo)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        buscarNuevasVersiones()
    }
  
    //MARK:- Cositas Table View
    
    func configurarTabla() {
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName : "MateriaCell", bundle : nil) ,forCellReuseIdentifier: "MateriaCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        
        controlActualizar = UIRefreshControl()
        controlActualizar.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        controlActualizar.tintColor = UIColor.black
        tableView.addSubview(controlActualizar)
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MateriasCoreData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MateriaCell", for: indexPath) as! MateriaCell
        
            let m = MateriasCoreData[indexPath.row]
            cell.NombreLabel.text = m.nombre
            cell.DescripcionTextView.text = m.descripcion
            cell.cellExists = true
            cell.DetallesView.backgroundColor = Utils.colorHash(m.nombre ?? "error" )
            cell.TituloView.backgroundColor = cell.DetallesView.backgroundColor
            cell.delegate = self
            cell.ReferenciaCD = m
            cell.VersionLabel.text = NSLocalizedString("version", comment: "") + ": \(m.version)"
        
            cell.AbrirButton.tag = indexPath.row
        
        UIView.animate(withDuration: 0) {
            cell.contentView.layoutIfNeeded()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        abrirMateria(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete) {            
            MateriasCoreData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }
    
    //MARK:- Otros
    
    func recuperarData(){
        do {
            MateriasCoreData = (try Context.fetch(Materia.fetchRequest())) as! [Materia]
        } catch {
            print("Error al recuperar las materias")
        }
    }
    
    @IBAction func longTouchHandler(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            var touchPoint = sender.location(in: self.view)
            touchPoint.y -= 70
            //tambien podria restarle la altura de la barra de navegacion + barra de estado?
            if let rowIndex = tableView.indexPathForRow(at:touchPoint) {
                expandirCelda(numero: rowIndex.row)
            }
        }
    }

    func abrirMateria (_ numero: Int) {
        self.performSegue(withIdentifier: "segueContenido", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueContenido" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let contenidoView = segue.destination as! ContenidoMateria
                let selectedRow = tableView.cellForRow(at: indexPath) as! MateriaCell
                contenidoView.titulo = selectedRow.NombreLabel.text!
                contenidoView.color = selectedRow.DetallesView.backgroundColor
                contenidoView.materiaAbierta = selectedRow.ReferenciaCD
            }
        }
    }
    
    func mostrarEmptyView() {
        if MateriasCoreData.isEmpty{
            let emptyView = (UINib(nibName: "MisMateriasEmptyView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView)
            emptyView.isHidden = false
            tableView.backgroundView = emptyView
        }else {
            if let v = tableView.backgroundView{
                v.isHidden = true
            }
        }
    }
    
    func expandirCelda(numero : Int) {
        self.tableView.beginUpdates()
        let previousCellTag = tagCeldaExpandida
        
        if ultimaCeldaExpandida != nil {
            if ultimaCeldaExpandida!.cellExists {
                self.ultimaCeldaExpandida!.animate(duration: 0.2, c: {
                    self.view.layoutIfNeeded()
                })
                if numero == tagCeldaExpandida {
                    tagCeldaExpandida = -1
                    ultimaCeldaExpandida = nil
                }
            }
        }
        
        if numero != previousCellTag {
            tagCeldaExpandida = numero
            ultimaCeldaExpandida = tableView.cellForRow(at: IndexPath(row: tagCeldaExpandida, section: 0)) as? MateriaCell
            self.ultimaCeldaExpandida!.animate(duration: 0.2, c: {
                self.view.layoutIfNeeded()
            })
        }
        self.tableView.endUpdates()
    }
    
    @objc func mostrarInfo() {
        let alerta = UIAlertController(title: nil , message: nil, preferredStyle: .actionSheet)
        
        let feedbackString = NSLocalizedString("Send feedback", comment: "")
        alerta.addAction(UIAlertAction(title: feedbackString, style: .default, handler: {_ in
            self.preguntarComentarios()
        }))
        
        let thirdsString = NSLocalizedString("Third party licences", comment: "")
        alerta.addAction(UIAlertAction(title: thirdsString, style: .default, handler: { _ in
            self.mostrarCreditos()
        }))
        
        let dismissString = NSLocalizedString("Dismiss", comment: "")
        alerta.addAction(UIAlertAction(title: dismissString, style: .cancel, handler: nil))
        self.present(alerta, animated: true, completion: nil)
    }
    
    func preguntarComentarios() {
        let thoughtString = NSLocalizedString("What are your thought about ReforzaTec?", comment: "")
        let sendString = NSLocalizedString("Send", comment: "");
        let warningString = NSLocalizedString("Do not include personal data", comment: "");
        let cancelString = NSLocalizedString("Cancel", comment: "");
        
        let comentariosAlert = UIAlertController(title: thoughtString, message: nil, preferredStyle: .alert)
        comentariosAlert.addAction(UIAlertAction(title: sendString, style: .default, handler: {(resultado: UIAlertAction) -> Void in
            if let comentario = comentariosAlert.textFields?.first!.text{
                print("Enviando: \(comentario)")
                let comentarioCodificado = comentario.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let url = URL(string: MateriaStruct.COMENTARIOS + comentarioCodificado!)
                print(url!.absoluteString)
                let session = URLSession.shared
                let task = session.dataTask(with: url!)
                task.resume()
            }
        }
        ))
        comentariosAlert.addAction(UIAlertAction(title: cancelString, style: .destructive, handler: nil))
        comentariosAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = warningString
            textField.returnKeyType = UIReturnKeyType.done
        })
        
        self.present(comentariosAlert, animated: true, completion: nil)
    }
    
    func mostrarCreditos() {
        var mensaje = String("\n\u{2022}")
        mensaje.append(NSLocalizedString("Icons designed by: ", comment: ""))
        mensaje.append("Freepik, SmashIcons ")
        mensaje.append(NSLocalizedString("and", comment: ""))
        mensaje.append(" Iconnice\n")
        mensaje.append(NSLocalizedString("from ", comment: ""))
        mensaje.append("www.flaticon.com \n\n")
        mensaje.append("\u{2022}DLRadioButton ")
        mensaje.append(NSLocalizedString(" by: ", comment: ""))
        mensaje.append("DavydLiu\n\n\n")
        mensaje.append("Instituto Tecnológico Superior de Uruapan")
        
        let dismissString = NSLocalizedString("Dismiss", comment: "")
        let creditosAlert = UIAlertController(title: "", message: mensaje, preferredStyle: .alert)
        creditosAlert.addAction(UIAlertAction(title: dismissString, style: .default, handler: nil))
        self.present(creditosAlert, animated: true, completion: nil)
    }

    func eliminarMateria(_ celda : MateriaCell) {
        let confirmationString = NSLocalizedString("Do you wish to delete the subject " , comment: "")
        let deleteString = NSLocalizedString("Delete", comment: "")
        let cancelString = NSLocalizedString("Cancel", comment: "")
        
        let alerta = UIAlertController(title: confirmationString + celda.NombreLabel.text! + "?", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        alerta.addAction(UIAlertAction(title: deleteString, style: UIAlertActionStyle.destructive, handler: {_ in
            let indexPath = self.tableView.indexPath(for: celda)!
            let mCD = celda.ReferenciaCD!
            self.borrarDeCoreData(materia: mCD)
            
            self.expandirCelda(numero: indexPath.row)
            self.tableView(self.tableView, commit: .delete, forRowAt: indexPath)
            
            self.mostrarEmptyView()
        }))
        alerta.addAction(UIAlertAction(title: cancelString, style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alerta, animated: true, completion: nil)
        
    }
    
    func borrarDeCoreData(materia: Materia) {
        borrarArchivos(de: materia)
        self.Context.delete(materia)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func borrarArchivos(de materia: Materia) {
        if let NSSetUnidades = materia.unidades{
            for ns in NSSetUnidades{
                let uni = ns as! Unidad
                do{
                    if let teoria = uni.teoria{
                        try FileManager().removeItem(at: MateriaStruct.URL_DIRECTORIO_DOCUMENTOS().appendingPathComponent(teoria))
                    }
                    if let ejemplo = uni.ejemplo{
                        try FileManager().removeItem(at: MateriaStruct.URL_DIRECTORIO_DOCUMENTOS().appendingPathComponent(ejemplo))
                    }
                }catch (let ex) {
                    print("error al borrar los archivos \(ex.localizedDescription)")
                }
            }
        }
    }
    
    func buscarNuevasVersiones() {
        Downloader.descargarListaMaterias(alFinalizar: { listaDescargada in
            for materiaCD in self.MateriasCoreData{
                if let materiaDescargada = listaDescargada[materiaCD.idMateria]{
                    if (materiaCD.version < materiaDescargada.Version) && (materiaCD.ignorarVersion != materiaDescargada.Version){
                        self.confirmarActualizacion(para: materiaCD, con: materiaDescargada)
                    }
                }
            }
        })
    }
    
    func confirmarActualizacion(para materia: Materia, con materiaNueva: MateriaStruct) {
        let titulo = NSLocalizedString("There's a newer version of: ", comment: "") + materia.nombre!
        let mensaje = NSLocalizedString("Would you like to download it? It will replace the current version", comment: "")
        
        let alert = UIAlertController.init(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {_ in
            self.actualizar(materia: materia, nueva: materiaNueva)
        }))
        alert.addAction(UIAlertAction.init(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: {_ in
            materia.ignorarVersion = materiaNueva.Version
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }))
        self.present(alert, animated: true, completion: {})
    }
    
    @objc func refresh(_ controlActualizar: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.buscarNuevasVersiones()
            self.controlActualizar.endRefreshing()
        })
    }
    
    func actualizar(materia: Materia, nueva: MateriaStruct) {
        var celda: MateriaCell?
        var indice: Int?
        for i in 0..<tableView.numberOfRows(inSection: 0){
            celda =  (tableView.cellForRow(at: IndexPath(row: i, section: 0)) as! MateriaCell)
            if celda?.ReferenciaCD?.idMateria == materia.idMateria{
                indice = i
                break
            }
        }
        
        celda?.estaDescargando = true
        borrarArchivos(de: materia)
        
        materia.nombre = nueva.Nombre
        materia.descripcion = nueva.Descripcion
        materia.version = nueva.Version
        materia.unidades  = nil
        
        if ultimaCeldaExpandida == celda{
            expandirCelda(numero: indice!)
        }
        
        celda?.NombreLabel.text = nueva.Nombre
        celda?.DescripcionTextView.text = nueva.Descripcion
        celda?.DetallesView.backgroundColor = Utils.colorHash(nueva.Nombre)
        celda?.TituloView.backgroundColor = celda!.DetallesView.backgroundColor
        celda?.ReferenciaCD = materia
        celda?.VersionLabel.text = NSLocalizedString("version", comment: "") + ": \(nueva.Version)"
        
        Downloader.actualizar(materia: materia, con: Context, alFinalizar: {
            DispatchQueue.main.async {
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                celda?.estaDescargando = false
            }
        })
    }

}

