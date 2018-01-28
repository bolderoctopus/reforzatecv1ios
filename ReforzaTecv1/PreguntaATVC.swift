//
//  PreguntaEvaluacionTVC.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 11/13/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit
// bug con el borde inferior del textfield, no se muestra
class PreguntaATVC: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var PreguntaL: UILabel!
    @IBOutlet weak var RespuestaTF: UITextField!
    
    var color:  UIColor!
    var respuestaCorrecta: String!
    var indiceDataSource: Int!
    weak var delegate: GuardarDatosProtocol?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        RespuestaTF.setBottomBorder()
        RespuestaTF.tintColor = color
        RespuestaTF.delegate = self
    }
    // implementando el delegado del textfield para ocultar el teclado al presionar la tecla de 'Done'
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func textChanged(_ sender: Any) {
        let text = RespuestaTF.text ??  ""
        delegate?.guardar(respuestAbierta: text, en: indiceDataSource)
    }

}

