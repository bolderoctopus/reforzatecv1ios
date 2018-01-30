//
//  PreguntaOMTVC.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 11/13/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit

class PreguntaOMTVC: UITableViewCell {
    @IBOutlet weak var PreguntaLabel: UILabel!
    @IBOutlet weak var OpcionesStackView: UIStackView!
    
    var color: UIColor!
    var opcionesIncorrectas: [String]!
    var opcionCorrecta: String!
    var indiceDataSource: Int!
    weak var delegate: GuardarDatosProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {        
        let botones = OpcionesStackView.arrangedSubviews
        for boton in botones{
            boton.removeFromSuperview()
        }
        delegate?.guaradar(RespuestasMultiples: botones, en: indiceDataSource)
        super.prepareForReuse()
    }
    
}
