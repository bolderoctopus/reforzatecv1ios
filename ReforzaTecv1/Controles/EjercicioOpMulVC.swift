//
//  EjercicioOpMulVC.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 7/31/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit

class EjercicioOpMulVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let RetrasoDeSegue: Int = 2
    var Ejercicios: [Ejercicio]!
    var EjercicioActual: Ejercicio!
   
    @IBOutlet weak var PreguntaTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var SiguienteButton: UIButton!
    
    @IBOutlet weak var AlturaTablaConstraint: NSLayoutConstraint!
    @IBOutlet weak var ScrollView: UIScrollView!    
    @IBOutlet weak var AlturaVCConstraint: NSLayoutConstraint!
    @IBOutlet weak var EspacioPreguntaTablaContstraint: NSLayoutConstraint!
    @IBOutlet weak var EspacioBotonTablaConstraint: NSLayoutConstraint!
    @IBOutlet weak var EspacioBottomBotonConstraint: NSLayoutConstraint!
    
    var fondo: CGPoint!
    var color : UIColor!
    var opcionesDeRespuesta : [String]!
    var respuesta : String!
    var botonSigOculto: Bool!
    var contestoBien: Bool!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        botonSigOculto = true
        SiguienteButton.layer.cornerRadius = 20
        SiguienteButton.layer.borderColor = color.cgColor
        SiguienteButton.layer.borderWidth = 1.5
        SiguienteButton.setTitleColor(UIColor.black, for: .normal)
        
        SiguienteButton.alpha = 0
        SiguienteButton.isEnabled = false
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EjercicioActual = Ejercicios.removeFirst()
        PreguntaTextView.text = EjercicioActual.textos ?? "error"
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
        PreguntaTextView.sizeToFit()
        AlturaTablaConstraint.constant = CGFloat(80 * tableView.numberOfRows(inSection: 0))
        EspacioPreguntaTablaContstraint.constant = CGFloat(self.view.frame.size.height / 12)
        
        
        // calcular el espacio entre la tabla y el boton
        var espacioLibre = self.view.frame.size.height
        espacioLibre -= (self.navigationController!.navigationBar.frame.height + PreguntaTextView.frame.origin.y + PreguntaTextView.frame.size.height + EspacioPreguntaTablaContstraint.constant + AlturaTablaConstraint.constant)
        
        espacioLibre -= SiguienteButton.frame.size.height
        espacioLibre -= 20
        
        var altura = CGFloat(0)
        if espacioLibre < 20 {
            EspacioBotonTablaConstraint.constant = 20
            EspacioBotonTablaConstraint.isActive = true
            EspacioBottomBotonConstraint.isActive = false
            altura += PreguntaTextView.frame.origin.y + PreguntaTextView.frame.size.height + EspacioPreguntaTablaContstraint.constant + AlturaTablaConstraint.constant + EspacioBotonTablaConstraint.constant + SiguienteButton.frame.size.height + 20
        }else {
            altura = self.view.frame.size.height  - self.navigationController!.navigationBar.frame.size.height
            - UIApplication.shared.statusBarFrame.height
            EspacioBotonTablaConstraint.isActive = false
            EspacioBottomBotonConstraint.isActive = true
        }
        
        fondo = CGPoint(x:0, y: altura)
        AlturaVCConstraint.constant = fondo.y
        configurarTabla()
        
        let ejercicioString = NSLocalizedString("Exercise", comment: "")
        let numero = " \(5 - Ejercicios.count)/5"
        self.title = ejercicioString + numero
        
    }

    // MARK:- TableView
    
    func configurarTabla() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName : "OpcionTableCell", bundle : nil) ,forCellReuseIdentifier: OpcionTableCell.REUSE_ID)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: OpcionTableCell.REUSE_ID, for:indexPath) as! OpcionTableCell
        celda.inicializar(titulo: opcionesDeRespuesta[indexPath.row], color: self.color)
        return celda
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
        if(celda.TextoLabel.text! == respuesta){
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
                celdaCorrecta.TextoLabel.textColor = UIColor.white
                celdaCorrecta.TextoLabel.layer.borderColor = #colorLiteral(red: 0.1906670928, green: 0.9801233411, blue: 0.474581778, alpha: 1)
            })

            UIView.animate(withDuration: 0.2, delay: 1, options: [.transitionFlipFromBottom], animations: {
                celdaCorrecta.TextoLabel.layer.backgroundColor = #colorLiteral(red: 0.1906670928, green: 0.9801233411, blue: 0.474581778, alpha: 1)
                celdaCorrecta.TextoLabel.transform = CGAffineTransform.init(scaleX: 1.1, y: 0.98)
                //celdaCorrecta.(bien: true)
            }, completion: {_ in
               UIView.animate(withDuration: 0.1, animations: {
                celdaCorrecta.TextoLabel.transform = CGAffineTransform.init(scaleX: 1, y: 1)
               })
                
                self.mostrarBoton()
            })
        }
    }
    
    @IBAction func MostrarSiguiente(_ sender: Any) {
        if(contestoBien){
            EjercicioActual.vecesAcertado += 1
        } else{
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
                    eVoz.ejercicios = Ejercicios
                    siguienteViewController = eVoz
                case "Opcion multiple":
                    let eOpMul = storyBoard.instantiateViewController(withIdentifier: "EjercicioOpMulVC") as! EjercicioOpMulVC
                    eOpMul.color = self.color
                    eOpMul.Ejercicios = Ejercicios
                    siguienteViewController = eOpMul
                case "Ordenar oracion":
                    let eOrOr = storyBoard.instantiateViewController(withIdentifier: "EjercicioOrdenarVC") as! EjercicioOrdenarVC
                    eOrOr.color = self.color
                    eOrOr.ejercicios = Ejercicios
                    siguienteViewController = eOrOr
                case "Escritura":
                    let eEs = storyBoard.instantiateViewController(withIdentifier: "EjercicioEscrituraVC") as! EjercicioEscrituraVC
                    eEs.color = self.color
                    eEs.ejercicios = Ejercicios
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
            self.ScrollView.scrollToView(view: self.SiguienteButton, animated: true)
            self.SiguienteButton.alpha = 1
            self.botonSigOculto = false
        })
        SiguienteButton.isEnabled = true
    }

}

