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
    var materiaAbierta: Materia!
    var ejerciciosPorAbrir: [Ejercicio]!
    var evaluacionPorAbrir: [Evaluacion]!
    var documentoPorAbrir: String!
    var dataSource: [UnidadStruct] = []
    
    let TeoriaString = NSLocalizedString("Notes", comment: "")
    let EjemplosString = NSLocalizedString("Examples", comment: "")
    let EjerciciosString = NSLocalizedString("Exercises", comment: "")
    let EvaluacionString = NSLocalizedString("Quiz", comment: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = true
        colorear()
        
        // comprobar que cosas tiene y que no para es mostrar
        let NSSetUnidades = materiaAbierta.unidades ?? []
        var i = 1
        for NSUni in NSSetUnidades{
            let uni = NSUni as! Unidad
            let nombre = uni.nombreUni ?? ""
            let descrip = uni.descripcionUni ?? ""
            
            var nuevaSeccion = UnidadStruct(nombre: nombre, descripcion: descrip, numero: i)
            if let _ = uni.ejemplo{
                nuevaSeccion.contenido.append(EjemplosString)
            }
            if let _ = uni.teoria{
                nuevaSeccion.contenido.append(TeoriaString)
            }
            if let e = uni.ejercicios{
                if (e.count != 0){
                    nuevaSeccion.contenido.append(EjerciciosString)
                }
            }
            if let ev = uni.evaluaciones{
                if (ev.count != 0){
                    nuevaSeccion.contenido.append(EvaluacionString)
                }
            }
            dataSource.append(nuevaSeccion)
            i += 1
        }
    }
    
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = titulo
    }
    //MARK: - tableView
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return materiaAbierta.unidades?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].contenido.count
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = dataSource[indexPath.section].contenido[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection indexPath: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (dataSource[indexPath.section].expanded) {
            return 44
        }else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        abrir(actividad: (tableView.cellForRow(at: indexPath)?.textLabel?.text!)!, enUnidad: indexPath.section)
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandibleHeaderView()
        let uni = materiaAbierta.unidades![section] as! Unidad
        header.customInit(title: uni.nombreUni ?? NSLocalizedString("Topic", comment: "") + " \(section)", section: section, delegate: self)
        return header
    }
    
    func toggleSelection(header: ExpandibleHeaderView, section: Int) {
        dataSource[section].expanded = !dataSource[section].expanded
        tableView.beginUpdates()
        for i in 0..<dataSource[section].contenido.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates()
        
    }
    
//MARK: - Otros
    
    func colorear () {
        if let c = color {
            UIApplication.shared.statusBarView?.backgroundColor = c
            self.navigationController?.navigationBar.tintColor = c
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : c]
        }
    }

    func abrir (actividad: String, enUnidad: Int) {
        switch actividad {
            case TeoriaString:
                documentoPorAbrir = (materiaAbierta.unidades![enUnidad] as! Unidad).teoria!
                self.performSegue(withIdentifier: "segueWeb", sender: self)
            case EjemplosString:
                documentoPorAbrir = (materiaAbierta.unidades![enUnidad] as! Unidad).ejemplo!
                self.performSegue(withIdentifier: "segueWeb", sender: self)
            case EjerciciosString:
                let uniAbierta = self.materiaAbierta.unidades![enUnidad] as! Unidad
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
            case EvaluacionString:
                evaluacionPorAbrir = (materiaAbierta.unidades![enUnidad] as! Unidad).evaluaciones?.allObjects as! [Evaluacion]
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
                eVoz.ejercicios = ejerciciosPorAbrir
                siguienteViewController = eVoz
            case "Opcion multiple":
                let eOpMul = storyBoard.instantiateViewController(withIdentifier: "EjercicioOpMulVC") as! EjercicioOpMulVC
                eOpMul.color = self.color
                eOpMul.Ejercicios = ejerciciosPorAbrir
                siguienteViewController = eOpMul
            case "Ordenar oracion":
                let eOrOr = storyBoard.instantiateViewController(withIdentifier: "EjercicioOrdenarVC") as! EjercicioOrdenarVC
                eOrOr.color = self.color
                eOrOr.ejercicios = ejerciciosPorAbrir
                siguienteViewController = eOrOr
            case "Escritura":
                let eEs = storyBoard.instantiateViewController(withIdentifier: "EjercicioEscrituraVC") as! EjercicioEscrituraVC
                eEs.color = self.color
                eEs.ejercicios = ejerciciosPorAbrir
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
            evaluacionView.preguntasEvaluacion = evaluacionPorAbrir
        default:
            print("Segue desconocido.")
        }
    }
}
