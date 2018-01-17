//
//  EjercicioOpMulVC.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 7/31/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit

//Por hacer la proxima vez:
//[] Llegar a un acuerdo sobre como mostrar el texto de la pregunta, habia unos bugs sobre la altura y al corregirlo salia 
//      otro bug con la alineacion
//      estaba pensando en dejar una altura fija (mejor dicho aspect ratio) para mostrar el texto, en caso de ser muy largo, pues si 
//      scroll pero el borde del textview deberia mostrar un blur en lugar de cortar el texto asi nada mas
//      y centrar el texto en ese espacio designado,lo mismo pensaba con las opciones de respuesta 

class EjercicioOpMulVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let RetrasoDeSegue: Int = 2
//para no estar descomentando cosas y probar rapido con breakpoints
    var debugVar = false
    var Ejercicios: [Ejercicio]!
    var EjercicioActual: Ejercicio!
   
    @IBOutlet weak var preguntaTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var BotonSiguiente: UIButton!
    
    @IBOutlet weak var AlturaTablaConstraint: NSLayoutConstraint!
    @IBOutlet weak var ScrollView: UIScrollView!    
    @IBOutlet weak var AlturaVCConstraint: NSLayoutConstraint!
    @IBOutlet weak var EspacioPreguntaTablaCotnstraint: NSLayoutConstraint!
    @IBOutlet weak var EspacioBotonTablaConstraint: NSLayoutConstraint!
    
    var Fondo: CGPoint!
    var color : UIColor!
    var opcionesDeRespuesta : [String]!// = ["incorrecto","incorrecto","incorrecto","correcto"]
    var respuesta : String!// = "correcto"
    var botonSigOculto: Bool!
    var contestoBien: Bool!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        
        botonSigOculto = true
        BotonSiguiente.layer.cornerRadius = 20
        BotonSiguiente.layer.borderColor = color.cgColor
        BotonSiguiente.layer.borderWidth = 1.5
        BotonSiguiente.setTitleColor(UIColor.black, for: .normal)
        //BotonSiguiente.frame.origin.y = self.view.bounds.size.height
        BotonSiguiente.alpha = 0.5
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EjercicioActual = Ejercicios.removeFirst()
        preguntaTextView.text = EjercicioActual.textos ?? "error"
        var  arreglo = EjercicioActual.respuestas!.characters.split{$0 == "|"}.map(String.init)
        for i in 0...(arreglo.count - 1){
            if(arreglo[i].starts(with: "@")){
                arreglo[i].remove(at: arreglo[i].startIndex)
                respuesta = arreglo[i]
                break
            }
        }
        
        opcionesDeRespuesta = arreglo
        opcionesDeRespuesta = opcionesDeRespuesta.shuffled()
        
        //Para que el textview tome la altura necesaria para mostrar su contenido sin hacer scroll
        preguntaTextView.sizeToFit()
        AlturaTablaConstraint.constant = CGFloat(80 * tableView.numberOfRows(inSection: 0))
        EspacioPreguntaTablaCotnstraint.constant = CGFloat(self.view.frame.size.height / 12)
        
        
        // calcular el espacio entre la tabla y el boton
        var espacioLibre = self.view.frame.size.height
        espacioLibre -= (preguntaTextView.frame.origin.y + preguntaTextView.frame.size.height + EspacioPreguntaTablaCotnstraint.constant + AlturaTablaConstraint.constant)
        print("alto de la pantalla: \(self.view.frame.size.height)")
        print("alto del boton")
        print(BotonSiguiente.frame.size.height)
        print("borde inferior de la tabla: \((preguntaTextView.frame.origin.y + preguntaTextView.frame.size.height + EspacioPreguntaTablaCotnstraint.constant + AlturaTablaConstraint.constant))")
        print("espacio libre sin boton: \(espacioLibre)")
        espacioLibre -= BotonSiguiente.frame.size.height
        print("espacio libre con boton: \(espacioLibre)")
        espacioLibre -= 20
        print("alto de la tabla: \(AlturaTablaConstraint.constant)")
        EspacioBotonTablaConstraint.constant = espacioLibre
        /*
        if(espacioLibre > 20){
            EspacioBotonTablaConstraint.constant += espacioLibre
            
        }else {
          EspacioBotonTablaConstraint.constant = 20
        }*/
        
        //EspacioBotonTablaConstraint.constant = 20
        
        
        
        
        
        // calculando altura del view controller
        var altura = CGFloat(0)
        altura += preguntaTextView.frame.origin.y + preguntaTextView.frame.size.height + EspacioPreguntaTablaCotnstraint.constant + AlturaTablaConstraint.constant + EspacioBotonTablaConstraint.constant + BotonSiguiente.frame.size.height + 20
        
        Fondo = CGPoint(x:0, y: altura)
        AlturaVCConstraint.constant = Fondo.y
        configurarTabla()
    }
   

    // MARK:- TableView
    
    func configurarTabla() {
        //aqui da nil cuando esta aparte del storyboard
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName : "OpcionTableCell", bundle : nil) ,forCellReuseIdentifier: OpcionTableCell.reuseId)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OpcionTableCell.reuseId, for:indexPath) as! OpcionTableCell
        cell.inicializar(titulo: opcionesDeRespuesta[indexPath.row], color: self.color)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return opcionesDeRespuesta.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        revisar(celda: tableView.cellForRow(at: indexPath) as! OpcionTableCell)
    }
    // MARK:- Otros
    func revisar( celda : OpcionTableCell) {
        if(celda.etiqueta.text! == respuesta){
            contestoBien = true
            celda.saltar(retraso: 0, fin: mostrarBoton())
        }else {
            contestoBien = false
            var celdaCorrecta = OpcionTableCell()
            for i in 0..<opcionesDeRespuesta.count{
                if(opcionesDeRespuesta[i] == respuesta){
                    celdaCorrecta = tableView.cellForRow(at: IndexPath(row:i, section:0)) as! OpcionTableCell
                    break
                }
            }
            celda.agitar()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: {
                celdaCorrecta.etiqueta.textColor = UIColor.white
                celdaCorrecta.etiqueta.layer.borderColor = #colorLiteral(red: 0.1906670928, green: 0.9801233411, blue: 0.474581778, alpha: 1)
            })

            UIView.animate(withDuration: 0.2, delay: 1, options: [.transitionFlipFromBottom], animations: {
                celdaCorrecta.etiqueta.layer.backgroundColor = #colorLiteral(red: 0.1906670928, green: 0.9801233411, blue: 0.474581778, alpha: 1)
                celdaCorrecta.etiqueta.transform = CGAffineTransform.init(scaleX: 1.1, y: 0.98)
                //celdaCorrecta.(bien: true)
            }, completion: {_ in
               UIView.animate(withDuration: 0.1, animations: {
                celdaCorrecta.etiqueta.transform = CGAffineTransform.init(scaleX: 1, y: 1)
               })
                
                self.mostrarBoton()
            })
        }
    }
    @IBAction func MostrarSiguiente(_ sender: Any) {
        if(contestoBien){
            //guardar acierto
            EjercicioActual.vecesAcertado += 1
        } else{
            //guardar fallo
            EjercicioActual.vecesFallado += 1
        }
        do{
            try EjercicioActual.managedObjectContext?.save()
        }catch{
            print("No se pudo guardar en CoreData")
        }
        
        if let siguienteE = Ejercicios.first{
            let storyBoard: UIStoryboard = (self.navigationController?.storyboard)!
            var siguienteViewController: UIViewController?
            switch siguienteE.tipo! {
                case "Voz":
                    let eVoz = storyBoard.instantiateViewController(withIdentifier: "EjercicioVozVC") as! EjercicioVozVC
                    eVoz.color = self.color
                    eVoz.Ejercicios = Ejercicios
                    siguienteViewController = eVoz
                case "Opcion multiple":
                    let eOpMul = storyBoard.instantiateViewController(withIdentifier: "EjercicioOpMulVC") as! EjercicioOpMulVC
                    eOpMul.color = self.color
                    eOpMul.Ejercicios = Ejercicios
                    siguienteViewController = eOpMul
                case "Ordenar oracion":
                    let eOrOr = storyBoard.instantiateViewController(withIdentifier: "EjercicioOrdenarVC") as! EjercicioOrdenarVC
                    eOrOr.color = self.color
                    eOrOr.Ejercicios = Ejercicios
                    siguienteViewController = eOrOr
                case "Escritura":
                    let eEs = storyBoard.instantiateViewController(withIdentifier: "EjercicioEscrituraVC") as! EjercicioEscrituraVC
                    eEs.color = self.color
                    eEs.Ejercicios = Ejercicios
                    siguienteViewController = eEs
                default:
                    print("Tipo de ejercicio desconocido: \(siguienteE.tipo!)")
            }
            if let sViewC = siguienteViewController{
                var stack = self.navigationController!.viewControllers
                stack.popLast()
                stack.append(sViewC)
                self.navigationController?.setViewControllers(stack, animated: true)
            }
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func mostrarBoton() {
        if(!botonSigOculto) {return}
        UIView.animate(withDuration: 0.6, animations: {
            self.ScrollView.scrollToView(view: self.BotonSiguiente, animated: true)
            self.BotonSiguiente.alpha = 1
            self.botonSigOculto = false
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "segueOrdenar":
            let view = segue.destination as! EjercicioOrdenarVC
            view.color = self.color
        default:
            print("Segue desconocido.")
        }
    }
}

