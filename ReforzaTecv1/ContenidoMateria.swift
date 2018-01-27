//
//  ContenidoMateria.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 7/25/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//
import UIKit
import CoreData

class ContenidoMateria: UITableViewController, ExpandibleHeaderRowDelegate   {
    
    var titulo : String = ""
    var color : UIColor!
    var MateriaAbierta: Materia!
    var ejerciciosPorAbrir: [Ejercicio]!
    var evaluacionPorAbrir: [Evaluacion]!
    var documentoPorAbrir: String!
    
    let teoriaString = NSLocalizedString("Notes", comment: "")
    let ejemplosSring = NSLocalizedString("Examples", comment: "")
    let ejerciciosString = NSLocalizedString("Exercises", comment: "")
    let evaluacionString = NSLocalizedString("Quiz", comment: "")
    
    var secciones: [UnidadStruct] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = true
        colorear()
        
        // comprobar que cosas tiene y que no para es mostrar
        let NSSetUnidades = MateriaAbierta.unidades ?? []
        var i = 1
        for NSUni in NSSetUnidades{
            let uni = NSUni as! Unidad
            let nombre = uni.nombreUni ?? ""
            let descrip = uni.descripcionUni ?? ""
            
            var nuevaSeccion = UnidadStruct(nombre: nombre, descripcion: descrip, numero: i)
            if let _ = uni.ejemplo{
                nuevaSeccion.contenido.append(ejemplosSring)
            }
            if let _ = uni.teoria{
                nuevaSeccion.contenido.append(teoriaString)
            }
            if let e = uni.ejercicios{
                if (e.count != 0){
                    nuevaSeccion.contenido.append(ejerciciosString)
                }
            }
            if let ev = uni.evaluaciones{
                if (ev.count != 0){
                    nuevaSeccion.contenido.append(evaluacionString)
                }
            }
            
            
            
            secciones.append(nuevaSeccion)
            i += 1
        }
    }
    
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = titulo
    }
//MARK: - tableView Cositas

    override func numberOfSections(in tableView: UITableView) -> Int {
        return MateriaAbierta.unidades?.count ?? 0
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return secciones[section].contenido.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = secciones[indexPath.section].contenido[indexPath.row]
        
            return cell

    }
    
   
    override func tableView(_ tableView: UITableView, heightForHeaderInSection indexPath: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (secciones[indexPath.section].expanded) {
            return 44
        }else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    //cehcar enums
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        abrir(actividad: (tableView.cellForRow(at: indexPath)?.textLabel?.text!)!, enUnidad: indexPath.section)
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandibleHeaderView()
        let uni = MateriaAbierta.unidades![section] as! Unidad
        header.customInit(title: uni.nombreUni ?? NSLocalizedString("Topic", comment: "") + " \(section)", section: section, delegate: self)
        return header
        
    }
    
    
    func toggleSelection(header: ExpandibleHeaderView, section: Int) {
        secciones[section].expanded = !secciones[section].expanded
        
        tableView.beginUpdates()
        for i in 0..<secciones[section].contenido.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates()
        
    }
//MARK: - Mis Metodos
    
    func colorear () {
        if let c = color {
            UIApplication.shared.statusBarView?.backgroundColor = c
            self.navigationController?.navigationBar.tintColor = c
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : c]
        }
    }

    //Dependiendo de la fila escojida nos lleva a la vista
    func abrir (actividad: String, enUnidad: Int) {
        switch actividad {
        case teoriaString:
            documentoPorAbrir = (MateriaAbierta.unidades![enUnidad] as! Unidad).teoria!
            self.performSegue(withIdentifier: "segueWeb", sender: self)
        case ejemplosSring:
            documentoPorAbrir = (MateriaAbierta.unidades![enUnidad] as! Unidad).ejemplo!
            self.performSegue(withIdentifier: "segueWeb", sender: self)
        case ejerciciosString:
            let uniAbierta = self.MateriaAbierta.unidades![enUnidad] as! Unidad
            ejerciciosPorAbrir = uniAbierta.ejercicios!.allObjects as! [Ejercicio]
            // ordenando para que primero salgan los que tienen mayor numero de veces falladas
            ejerciciosPorAbrir.sort{ e1, e2 in
                return e1.vecesFallado > e2.vecesFallado
            }
            // solo mostrar 5 ejercicios
            if(ejerciciosPorAbrir.count > 5){
                var arregloTemporal: [Ejercicio] = []
                for i in 0...4{
                    arregloTemporal.append(ejerciciosPorAbrir[i])
                }
                ejerciciosPorAbrir = arregloTemporal
            }
            self.abrirEjercicio()
        case evaluacionString:
            evaluacionPorAbrir = (MateriaAbierta.unidades![enUnidad] as! Unidad).evaluaciones?.allObjects as! [Evaluacion]
            self.performSegue(withIdentifier: "segueEvaluacion", sender: self)
        default:
            print("Actividad desconocida: '\(actividad)'")
        }
    }
    
    func abrirEjercicio(){
        let e =  ejerciciosPorAbrir.first!
        let storyBoard: UIStoryboard = (self.navigationController?.storyboard)!
        var siguienteViewController: UIViewController?
        switch e.tipo!{
            case "Voz":
                let eVoz = storyBoard.instantiateViewController(withIdentifier: "EjercicioVozVC") as! EjercicioVozVC
                eVoz.color = self.color
                eVoz.Ejercicios = ejerciciosPorAbrir
                siguienteViewController = eVoz
            case "Opcion multiple":
                let eOpMul = storyBoard.instantiateViewController(withIdentifier: "EjercicioOpMulVC") as! EjercicioOpMulVC
                eOpMul.color = self.color
                eOpMul.Ejercicios = ejerciciosPorAbrir
                siguienteViewController = eOpMul
            case "Ordenar oracion":
                let eOrOr = storyBoard.instantiateViewController(withIdentifier: "EjercicioOrdenarVC") as! EjercicioOrdenarVC
                eOrOr.color = self.color
                eOrOr.Ejercicios = ejerciciosPorAbrir
                siguienteViewController = eOrOr
            case "Escritura":
                let eEs = storyBoard.instantiateViewController(withIdentifier: "EjercicioEscrituraVC") as! EjercicioEscrituraVC
                eEs.color = self.color
                eEs.Ejercicios = ejerciciosPorAbrir
                siguienteViewController = eEs
            default:
                print("Tipo de ejercicio desconocido: \(e.tipo!)")
        }
        if let sViewC = siguienteViewController{
            self.navigationController?.pushViewController(sViewC, animated: true)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "segueWeb":
            let webView = segue.destination as! PDFWebViewController
            webView.color = self.color
            webView.archivoPorAbrir = documentoPorAbrir
        case "segueEvaluacion":
            let evaluacionView = segue.destination as! EvaluacionTVC
            evaluacionView.color = self.color
            evaluacionView.PreguntasEvaluacion = evaluacionPorAbrir
        default:
            print("Segue desconocido.")
        }
    }
}
