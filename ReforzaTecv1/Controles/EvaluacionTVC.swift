//
//  EvaluacionTVC.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 11/13/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit


/**
 Permite guardar lo que el usuario ha contestado en el dataSource de la tableView para que cuando
 las preguntas no sean visibles no se pierda su respuesta al reciclar la vista.
 */
protocol GuardarDatosProtocol: class{
    func guardar(respuestAbierta: String, en indice: Int)
    func guaradar(RespuestasMultiples: [UIView], en indice: Int)
}
class EvaluacionTVC: UITableViewController, GuardarDatosProtocol {
    
    /**
     Representa el modelo de un pregunta que se muestra.
     */
    struct PreguntaStruct {
        var indice: Int
        var texto: String
        var tipo: tipos
        var respuestaCorrecta: String
        var opciones: [String]!
        var botones: [UIView]!
        var respuestaAbierta: String!
        var estado: estados!
        var id: Int16
        enum tipos {
            case abierta
            case opcionM
        }
        enum estados {
            case sinCalificar
            case correcto
            case incorrecto
        }
        
        init(texto: String, respuesta: String, indice: Int, id: Int16) {
            self.indice = indice
            self.texto = texto
            self.tipo = .abierta
            self.respuestaCorrecta = respuesta
            self.respuestaAbierta = ""
            self.opciones = nil
            self.botones = nil
            self.estado = .sinCalificar
            self.id = id
        }
        
        init(texto: String, respuesta: String, opciones: [String], ancho: CGFloat, color: UIColor, indice: Int, id: Int16) {
            self.indice = indice
            self.texto = texto
            self.tipo = .opcionM
            self.respuestaCorrecta = respuesta
            self.opciones = opciones
            self.id = id
            var todas = opciones
            todas.append(respuesta)
            
            self.botones = arregloDeBotones(con: todas, ancho: ancho, color: color)
            self.estado = .sinCalificar
            
        }
        
        func arregloDeBotones(con strings: [String], ancho: CGFloat, color: UIColor)-> [UIView] {
            var botones: [DLRadioButton] = []
            for s in strings{
                let radioButton = DLRadioButton(frame: CGRect(x:0, y:0, width: ancho,  height: 30))
                radioButton.setTitle(s, for: [])
                radioButton.setTitleColor(UIColor.black, for: [])
                radioButton.iconColor = color
                radioButton.indicatorColor = color
                radioButton.contentHorizontalAlignment = .left
                radioButton.isMultipleSelectionEnabled = true
                botones.append(radioButton)
            }
            return botones
        }
        mutating func esCorrecto() ->Bool{
          switch self.tipo {
             case .abierta:
                if (respuestaCorrecta.caseInsensitiveCompare(respuestaAbierta) == ComparisonResult.orderedSame){
                    estado = .correcto
                    return true
                }else{
                    estado = .incorrecto
                    return false
                 }
             case .opcionM:
                var estaBien = false
                for v in botones{
                    let boton = v as! DLRadioButton
                    if(boton.isSelected){
                        if(boton.titleLabel!.text! == respuestaCorrecta){
                            estaBien = true
                        }else {
                            estaBien = false
                            break
                        }
                    }
                }
            
                estado = estaBien ? estados.correcto : estados.incorrecto
                return estaBien
             }
        }
    }
    
    
    @IBOutlet weak var ResultadosStackView: UIStackView!
    @IBOutlet weak var AciertosLabel: UILabel!
    @IBOutlet weak var ErroresLabel: UILabel!
    @IBOutlet weak var TiempoLabel: UILabel!
    @IBOutlet weak var RevisarButton: UIButton!
    @IBOutlet weak var AlturaConstraint: NSLayoutConstraint!
    @IBOutlet weak var ResultadosView: UIView!
    
    var horaInicial: NSDate!
    var dataSource: [PreguntaStruct]!
    var color: UIColor!
    var preguntasEvaluacion: [Evaluacion]!

    override func viewDidLoad() {
        super.viewDidLoad()
        inicializarDataSource()
   
        RevisarButton.layer.borderWidth = 1.5
        RevisarButton.layer.borderColor = color.cgColor
        RevisarButton.layer.cornerRadius = 10
        RevisarButton.setTitleColor(color,for: .normal)
        RevisarButton.backgroundColor = UIColor.white
        
        ResultadosView.backgroundColor = UIColor.white
        ResultadosView.layer.borderWidth = 1.5
        ResultadosView.layer.borderColor = color.cgColor
        ResultadosView.layer.cornerRadius = 10
        ResultadosView.alpha = 0
        AlturaConstraint.constant = 0
        
        tableView.register(UINib(nibName: "PreguntaATVC", bundle: nil), forCellReuseIdentifier: "preguntaAbierta")
        tableView.register(UINib(nibName: "PreguntaOMTVC", bundle: nil), forCellReuseIdentifier: "preguntaOpcion")
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
        self.title = NSLocalizedString("Quiz", comment: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        horaInicial = NSDate()
    }
    
    @IBAction func RevisarA(_ sender: Any) {
        contarAciertos()
        TiempoLabel.text?.append(tiempoTranscurrido())
        UIView.animate(withDuration: 0.3, animations: {
            self.AlturaConstraint.constant = 128
            self.ResultadosView.alpha = 1
        })
        RevisarButton.isEnabled = false
    }
    
    // MARK: - Table view
    override func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    // MARK: - Otros

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let p = dataSource[indexPath.row]
        switch p.tipo {
            case .abierta:
                let cell = tableView.dequeueReusableCell(withIdentifier: "preguntaAbierta", for: indexPath)as! PreguntaATVC
                cell.PreguntaLabel.text = String(indexPath.row + 1) + ". " + p.texto
                cell.color = color
                cell.respuestaCorrecta = p.respuestaCorrecta
                cell.RespuestaTextField.text = p.respuestaAbierta
                cell.delegate = self
                cell.indiceDataSource = p.indice
                if(p.estado == .correcto){
                    cell.RespuestaTextField.textColor = UIColor.green
                    cell.RespuestaTextField.isEnabled = false
                }else if(p.estado == .incorrecto){
                    cell.RespuestaTextField.textColor = UIColor.red
                    cell.RespuestaTextField.isEnabled = false
                    cell.RespuestaTextField.attributedText = tachar(string: p.respuestaAbierta)
                }
                return cell
            case .opcionM:
                let cell = tableView.dequeueReusableCell(withIdentifier: "preguntaOpcion", for: indexPath)as! PreguntaOMTVC
                cell.PreguntaLabel.text = String(indexPath.row + 1) + ". " + p.texto
                cell.color = color
                cell.delegate = self
                cell.indiceDataSource = p.indice
                for case let boton as DLRadioButton in p.botones {
                    if(p.estado == PreguntaStruct.estados.correcto && boton.isSelected){
                        boton.tintColor = UIColor.green
                        boton.setTitleColor(UIColor.green, for: [])
                    }else if(p.estado == .incorrecto && boton.isSelected){
                        boton.tintColor = UIColor.red
                        boton.setTitleColor(UIColor.red, for: [])
                        boton.setAttributedTitle(tachar(string: boton.titleLabel!.text!), for: [])
                    }
                    if(p.estado != PreguntaStruct.estados.sinCalificar){
                        boton.isEnabled = false
                    }
                    cell.OpcionesStackView.addArrangedSubview(boton)
                }
                return cell
        }
    }
    
    private func inicializarDataSource() {
        dataSource = []
        var indice = 0
        for p in preguntasEvaluacion{
            var  arreglo = p.respuestas!.characters.split{$0 == "|"}.map(String.init)
            if(arreglo.count == 1){
                var rCorrecta = arreglo.first!
                rCorrecta.remove(at: rCorrecta.startIndex)
                dataSource.append(PreguntaStruct(texto: p.pregunta!, respuesta: rCorrecta, indice: indice, id: p.idEv))
                
            }else{
                var rCorrecta = ""
                for i in 0...(arreglo.count - 1){
                    if(arreglo[i].starts(with: "@")){
                        rCorrecta = arreglo.remove(at: i)
                        break
                    }
                }
                rCorrecta.remove(at: rCorrecta.startIndex)
                dataSource.append(PreguntaStruct(texto: p.pregunta!, respuesta: rCorrecta, opciones: arreglo, ancho: tableView.frame.width, color: color, indice: indice, id: p.idEv))
            }
            indice += 1
        }
    }
    
  
    
    func tiempoTranscurrido() -> String {
        let segundos = Int(horaInicial.timeIntervalSinceNow.magnitude)
        let minutos = Int(segundos/60)
        let segundosString = NSLocalizedString("seconds", comment: "")
        
        if(minutos == 0) {
            return " \(segundos % 60) " + segundosString
        } else{
            let minutosString = NSLocalizedString("minutes", comment: "")
            return " \(minutos) \(minutosString):\(segundos % 60) \(segundosString)"
        }
        
    }
    
    func tachar(string: String) -> NSAttributedString{
        let attributedString: NSMutableAttributedString =  NSMutableAttributedString(string: string)
        attributedString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    func contarAciertos() {
        var aciertos = 0
        var fallos = 0
        var resultados: [String: String] = [:]
        for i in 0...(dataSource.count - 1){
            let id: String = String(dataSource[i].id)
            var r: String
            if (dataSource[i].esCorrecto()){
                aciertos += 1
                r = "1"
            }else {
                fallos += 1
                r = "0"
            }
            resultados[id] = r
        }
        subirCalificaciones(resultados)
        AciertosLabel.text?.append(" \(aciertos)")
        ErroresLabel.text?.append(" \(fallos)")
        tableView.reloadData()
    }
    
    func subirCalificaciones(_ resultados: [String: String]) {
        do{
            let json = try JSONSerialization.data(withJSONObject: resultados, options: [] )
            let url = URL (string: (MateriaStruct.CALIFICACIONES + String(preguntasEvaluacion.first!.unidad!.idUni)) )!
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = ("resultados=" + String(data:json, encoding: .utf8)!).data(using: .utf8)!
            request.httpMethod = "POST"
            let task = URLSession.shared.dataTask(with: request){data, response, error in
                guard  error == nil else{
                    print("error: \(error!)")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                    print("response: \(response!)")
                }
                
                if let responseString = String(data: data!, encoding: .utf8){
                    print("respuesta: \(responseString)")
                }
                
            }
            task.resume()
        }catch {
            print("No fue posible enviar al servidor.")
        }
 
    }
    
    // MARK:- Definicion de protocolos
    func guardar(respuestAbierta: String, en indice: Int) {
        dataSource[indice].respuestaAbierta = respuestAbierta
    }
    
    func guaradar(RespuestasMultiples: [UIView], en indice: Int) {
        dataSource[indice].botones = RespuestasMultiples
    }
    
}
