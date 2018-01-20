//
//  EvaluacionTVC.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 11/13/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit
// Guarda las datos de celdas en el data soruce antes de que sean reutilizadas por la table view
protocol GuardarDatosProtocol: class{
    func guardar(respuestAbierta: String, en indice: Int)
    func guaradar(RespuestasMultiples: [UIView], en indice: Int)
}
class EvaluacionTVC: UITableViewController, GuardarDatosProtocol {
    
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
        // y practicamente este es el constructor para cuando es de abierta
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
        // practicmente este es el constructor para cuando es de opcionM
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
    
    
    @IBOutlet weak var ResultadosSV: UIStackView!
    @IBOutlet weak var AciertosL: UILabel!
    @IBOutlet weak var ErroresL: UILabel!
    @IBOutlet weak var TiempoL: UILabel!
    @IBOutlet weak var RevisarB: UIButton!
    @IBOutlet weak var AlturaC: NSLayoutConstraint!
    @IBOutlet weak var ResultadosV: UIView!
    
    var horaInicial: NSDate!
    var dataSource: [PreguntaStruct]!
    var color: UIColor!
    var PreguntasEvaluacion: [Evaluacion]!

    override func viewDidLoad() {
        super.viewDidLoad()
        inicializarDataSource()
       
        
        RevisarB.layer.borderWidth = 1.5
        RevisarB.layer.borderColor = color.cgColor
        RevisarB.layer.cornerRadius = 10
        RevisarB.setTitleColor(color,for: .normal)
        RevisarB.backgroundColor = UIColor.white
        
        ResultadosV.backgroundColor = UIColor.white
        ResultadosV.layer.borderWidth = 1.5
        ResultadosV.layer.borderColor = color.cgColor
        ResultadosV.layer.cornerRadius = 10
        ResultadosV.alpha = 0
        AlturaC.constant = 0
        
        tableView.register(UINib(nibName: "PreguntaATVC", bundle: nil), forCellReuseIdentifier: "preguntaAbierta")
        tableView.register(UINib(nibName: "PreguntaOMTVC", bundle: nil), forCellReuseIdentifier: "preguntaOpcion")
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        horaInicial = NSDate()
    }
    
    // revisarAction
    @IBAction func RevisarA(_ sender: Any) {
        // calificar
        // mostrar resultados
        contarAciertos()
        TiempoL.text?.append(tiempoTranscurrido())
        UIView.animate(withDuration: 0.3, animations: {
            self.AlturaC.constant = 128
            self.ResultadosV.alpha = 1
        })
        RevisarB.isEnabled = false
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let p = dataSource[indexPath.row]
        switch p.tipo {
            case .abierta:
                let cell = tableView.dequeueReusableCell(withIdentifier: "preguntaAbierta", for: indexPath)as! PreguntaATVC
                cell.PreguntaL.text = String(indexPath.row + 1) + ". " + p.texto
                cell.color = color
                cell.respuestaCorrecta = p.respuestaCorrecta
                cell.RespuestaTF.text = p.respuestaAbierta
                cell.delegate = self
                cell.indiceDataSource = p.indice
                if(p.estado == .correcto){
                    cell.RespuestaTF.textColor = UIColor.green
                    cell.RespuestaTF.isEnabled = false
                }else if(p.estado == .incorrecto){
                    cell.RespuestaTF.textColor = UIColor.red
                    cell.RespuestaTF.isEnabled = false
                    cell.RespuestaTF.attributedText = tachar(string: p.respuestaAbierta)
                }
                return cell
            case .opcionM:
                let cell = tableView.dequeueReusableCell(withIdentifier: "preguntaOpcion", for: indexPath)as! PreguntaOMTVC
                cell.PreguntaL.text = String(indexPath.row + 1) + ". " + p.texto
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
                    cell.OpcionesSV.addArrangedSubview(boton)
                }
                return cell
        }
    }
    
    private func inicializarDataSource() {
        dataSource = []
        var indice = 0
        for p in PreguntasEvaluacion{
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
                //dataSource.append(PreguntaStruct(texto: p.pregunta!, respuesta: rCorrecta, opciones: arreglo, ancho: tableView.frame.width, color: color, indice: Int(p.idEv)))
            }
            indice += 1
        }
    }
    
    // MARK:- Definicion de protocolos
    func guardar(respuestAbierta: String, en indice: Int) {
        dataSource[indice].respuestaAbierta = respuestAbierta
    }
    
    func guaradar(RespuestasMultiples: [UIView], en indice: Int) {
        dataSource[indice].botones = RespuestasMultiples
    }
    
    func tiempoTranscurrido() -> String {
        let segundos = Int(horaInicial.timeIntervalSinceNow.magnitude)
        let minutos = Int(segundos/60)
        
        if(minutos == 0) {
            return " \(segundos % 60) segundos"
        } else{
            return " \(minutos) minutos:\(segundos % 60) segundos"
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
            var id: String = String(dataSource[i].id)
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
        
        AciertosL.text?.append(" \(aciertos)")
        ErroresL.text?.append(" \(fallos)")
        tableView.reloadData()
    }
    
    func subirCalificaciones(_ resultados: [String: String]) {
        do{
            let json = try JSONSerialization.data(withJSONObject: resultados, options: [] )
            //print(String(data:json, encoding: .utf8)!)
            let url = URL (string: (MateriaObj.CALIFICACIONES + String(PreguntasEvaluacion.first!.unidad!.idUni)) )!
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
            
        // poner parametros
        
    }
    
}
