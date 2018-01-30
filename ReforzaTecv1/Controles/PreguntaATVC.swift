//
//  PreguntaEvaluacionTVC.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 11/13/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit

class PreguntaATVC: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var PreguntaLabel: UILabel!
    @IBOutlet weak var RespuestaTextField: UITextField!
    
    var color:  UIColor!
    var respuestaCorrecta: String!
    var indiceDataSource: Int!
    weak var delegate: GuardarDatosProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        RespuestaTextField.setBottomBorder()
        RespuestaTextField.tintColor = color
        RespuestaTextField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func textChanged(_ sender: Any) {
        let text = RespuestaTextField.text ??  ""
        delegate?.guardar(respuestAbierta: text, en: indiceDataSource)
    }

}

