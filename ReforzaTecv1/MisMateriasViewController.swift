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
    
    let color : UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    @IBOutlet weak var tableView: CustomUITableView!
    var materiasDescargadas : [Materia] = []
    var lastCell : CustomTableViewCell?//   = CustomTableViewCell ()//guarda la celda que esta expandida?
    var tagCeldaExpandida = -1//identifica a la celda abierta
    
    //lo puse en view did appear por que en view did load no funcionaba?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Restablece la barra de estado y el tinte a color transparente (lol)y negro, si no, cuando regresas de una materia, la barra conservaria el color pasado.
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = color
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : color]
        
        
        // hacer un struct y no pasar referencia de core data a la celda?
        recuperarData()

        tableView.reloadData()

    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configurarTabla()
        let botonInfo = UIButton.init(type: .infoLight)
        botonInfo.addTarget(self, action: #selector(mostrarInfo), for: .touchUpInside)
        let barButton = UIBarButtonItem.init(customView: botonInfo)
        self.navigationItem.leftBarButtonItem = barButton
    }
 
    func recuperarData(){
        do {
            materiasDescargadas = (try context.fetch(Materia.fetchRequest())) as! [Materia]
        } catch {
            print("Error al recuperar las materias")
        }
    }
    
    @IBAction func longTouchHandler(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            var touchPoint = sender.location(in: self.view)
            touchPoint.y -= 70
            //seria mejor restarle la altura de la barra de navegacion + barra de estado?
            if let rowIndex = tableView.indexPathForRow(at:touchPoint) {
                expandirCelda(numero: rowIndex.row)
            }
        }
    }
  
    //MARK:- Cositas Table View
    func configurarTabla() {
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(UINib(nibName : "CustomTableViewCell", bundle : nil) ,forCellReuseIdentifier: "CustomTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return materiasDescargadas.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        
        //if !cell.cellExists {
            let m = materiasDescargadas[indexPath.row]
            cell.nombreLabel.text = m.nombre
            cell.descripcionTextView.text = m.descripcion
            cell.cellExists = true
            cell.detailsView.backgroundColor = Utils.colorHash(m.nombre ?? "error" )
            cell.titleView.backgroundColor = cell.detailsView.backgroundColor
            cell.delegate = self
            cell.referenciaCD = m
            
            //para saber cual boton pertenece a cual materia
            cell.openButton.tag = indexPath.row
        //}
        
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
            materiasDescargadas.remove(at: indexPath.row)//tal vez esto deberia estar en eliminarMateria(celda)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }
    
    //MARK:- Cositas Segue

    //curr in use
    func abrirMateria (_ numero: Int) {
        self.performSegue(withIdentifier: "segueContenido", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueContenido" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let contenidoView = segue.destination as! ContenidoMateria
                let selectedRow = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
                contenidoView.titulo = selectedRow.nombreLabel.text!
                contenidoView.color = selectedRow.detailsView.backgroundColor
                contenidoView.MateriaAbierta = selectedRow.referenciaCD
            }
        }
    }
    
    //MARK:- Cosas extra


    func expandirCelda(numero : Int) {
        self.tableView.beginUpdates()
        let previousCellTag = tagCeldaExpandida
        
        if lastCell != nil {
            if lastCell!.cellExists {
                self.lastCell!.animate(duration: 0.2, c: {
                    self.view.layoutIfNeeded()
                })
                if numero == tagCeldaExpandida {//si la celda que quiere volver a abrirse ya esta abierta se cierra
                    tagCeldaExpandida = -1// menos uno indica que no hay celdas abiertas
                    lastCell = nil// = CustomTableViewCell()//seria mas rapido modificar lastCell.exists?
                }
            }
        }
        
        if numero != previousCellTag {
            tagCeldaExpandida = numero
            lastCell = tableView.cellForRow(at: IndexPath(row: tagCeldaExpandida, section: 0)) as? CustomTableViewCell
            self.lastCell!.animate(duration: 0.2, c: {
                self.view.layoutIfNeeded()
            })
        }
        
        self.tableView.endUpdates()
    }

    
    @objc func mostrarInfo() {
        let alerta = UIAlertController(title: nil , message: nil, preferredStyle: .actionSheet)
        // enviar comentarios
        alerta.addAction(UIAlertAction(title:"Enviar comentarios", style: .default, handler: {_ in
            self.preguntarComentarios()
        }))
        
        // mostrar creditos
        alerta.addAction(UIAlertAction(title:"Licencias de terceros", style: .default, handler: { _ in
            self.mostrarCreditos()
        }))
        
        // cancelar
        alerta.addAction(UIAlertAction(title:"Ocultar", style: .cancel, handler: nil))
        self.present(alerta, animated: true, completion: nil)
    }
    
    func preguntarComentarios() {
        
        let comentariosAlert = UIAlertController(title: "¿Qué piensas de la aplicación?", message: nil, preferredStyle: .alert)
        comentariosAlert.addAction(UIAlertAction(title: "Enviar", style: .default, handler: {(resultado: UIAlertAction) -> Void in
            if let comentario = comentariosAlert.textFields?.first!.text{
                print("Enviando: \(comentario)")
                let comentarioCodificado = comentario.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let url = URL(string: MateriaObj.COMENTARIOS + comentarioCodificado!)
                print(url!.absoluteString)
                let session = URLSession.shared
                let task = session.dataTask(with: url!)
                task.resume()
                
            }
        }
        ))
        comentariosAlert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        
        comentariosAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = "No incluyas datos personales"
            textField.returnKeyType = UIReturnKeyType.done
            
        })
        
        self.present(comentariosAlert, animated: true, completion: nil)
    }
    
    func mostrarCreditos() {
        let creditosAlert = UIAlertController(title: "Mostrar licencias", message: "por enlistar terceros", preferredStyle: .alert)
        creditosAlert.addAction(UIAlertAction(title: "Ocultar", style: .default, handler: nil))
        self.present(creditosAlert, animated: true, completion: nil)
    }
    
    
    //Cumpliendo con el delegado del CustomTableView para que al darle en el boton de borrar de la celda se llame aqui esto y se borre
    //Elimina la materia de coreData y la celda del tableview
    //primero muestra
    func eliminarMateria(_ celda : CustomTableViewCell) {
        let alerta = UIAlertController(title: "¿Deseas borrar la materia \(celda.nombreLabel.text!)?", message: "Tu progreso será perdido", preferredStyle: UIAlertControllerStyle.actionSheet)
        alerta.addAction(UIAlertAction(title: "Borrar", style: UIAlertActionStyle.destructive, handler: {_ in
            let indexPath = self.tableView.indexPath(for: celda)!
            let coreData = celda.referenciaCD!
        
            if let NSSetUnidades = coreData.unidades{
                for ns in NSSetUnidades{
                    let uni = ns as! Unidad
                    do{
                        if let teoria = uni.teoria{
                            try FileManager().removeItem(at: MateriaObj.URL_DIRECTORIO_DOCUMENTOS().appendingPathComponent(teoria))
                            print("archivo borrado \(teoria)")
                        }
                        if let ejemplo = uni.ejemplo{
                            try FileManager().removeItem(at: MateriaObj.URL_DIRECTORIO_DOCUMENTOS().appendingPathComponent(ejemplo))
                            print("archivo borrado \(ejemplo)")
                        }
                    }catch (let ex) {
                       print("error al borrar los archivos \(ex.localizedDescription)")
                    }
                }
            }
            self.expandirCelda(numero: indexPath.row)
            self.tableView(self.tableView, commit: .delete, forRowAt: indexPath)
            
            self.context.delete(coreData)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            //self.lastCell = nil
        }))
        alerta.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel, handler: {_ in
            print("Cancelado, nada se borrara.")
        }))
        self.present(alerta, animated: true, completion: nil)
        
    }

}

