//
//  EjercicioVozVC.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 11/3/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit
import Speech

class EjercicioVozVC: UIViewController, SFSpeechRecognizerDelegate {    
    
    @IBOutlet weak var MicrofonoMuteButton: UIBarButtonItem!
    @IBOutlet weak var PretuntaTextView: UITextView!
    @IBOutlet weak var RevisarButton: UIButton!
    @IBOutlet weak var MicrofonoButton: UIButton!
    @IBOutlet weak var EntradaTextField: UITextField!
    @IBOutlet weak var CalificacionImagenView: UIImageView!
    @IBOutlet weak var AlturaDeImagenConstraint: NSLayoutConstraint!
    @IBOutlet weak var IndicadorDeActividad: UIActivityIndicatorView!
    
    let SpeechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "es-MX"))
    var solicitudDeReconocimiento: SFSpeechAudioBufferRecognitionRequest?
    var tareaDeReconocimiento: SFSpeechRecognitionTask?
    let MotorDeAudio = AVAudioEngine()
    
    var respuestaCorrecta:String!
    var color: UIColor!
    var ejercicios: [Ejercicio]!
    var ejercicioActual: Ejercicio!
    var yaFueRevisado = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ejercicioActual = ejercicios.removeFirst()
        respuestaCorrecta = ejercicioActual.respuestas!
        PretuntaTextView.text = ejercicioActual.textos!

        MicrofonoMuteButton.tintColor = color
        IndicadorDeActividad.tintColor = color
        IndicadorDeActividad.alpha = 0
        
        EntradaTextField.text = ""
        // para evitar que se muesre un teclado en el cmapo de texto
        EntradaTextField.inputView = UIView()

        iniciarBoton()
        
        AlturaDeImagenConstraint.constant = 0
        CalificacionImagenView.alpha = 0
        

        MicrofonoButton.isEnabled = false
        
        SpeechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization({(estadoAutorizacion) in
            var habilitarBoton = false
            switch estadoAutorizacion{
            case .authorized:
                habilitarBoton = true
            case .denied:
                habilitarBoton = false
            case .notDetermined:
                habilitarBoton = false
            case .restricted:
                habilitarBoton = false
            }
            OperationQueue.main.addOperation {
                self.MicrofonoButton.isEnabled = habilitarBoton
            }
        })
        let ejercicioString = NSLocalizedString("Exercise", comment: "")
        let numero = " \(5 - ejercicios.count)/5"
        self.title = ejercicioString + numero
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        revisarConexion()
    }
    @objc func accionDelBotonRevisar(sender: UIButton) {
        if yaFueRevisado{
            siguienteEjercicio()
        } else {
            mostrarCalificacion()
        }
    }
  
    // MARK: - Otros
    
    func iniciarBoton() {
        RevisarButton.backgroundColor = UIColor.white
        RevisarButton.addTarget(self, action: #selector(accionDelBotonRevisar), for: .touchDown)
        RevisarButton.layer.cornerRadius = 10
        RevisarButton.layer.borderWidth = 1.5
        RevisarButton.layer.borderColor = color.cgColor
        RevisarButton.setTitleColor( #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1), for: .disabled)
        RevisarButton.isEnabled = false
    }
    
    @IBAction func accionDelBotonGrabar(_ sender: Any) {
        RevisarButton.isEnabled = true
        if MotorDeAudio.isRunning{
            MotorDeAudio.stop()
            solicitudDeReconocimiento?.endAudio()
            MicrofonoButton.isEnabled = false
        } else{
            iniciarGrabacion()
        }
    }
    
    @IBAction func MuteMicrofono(_ sender: Any) {
        if(MotorDeAudio.isRunning){
            detenerGrabacion()
        }
        MicrofonoButton.isEnabled = false
        RevisarButton.isEnabled = true
        self.RevisarButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
        yaFueRevisado = true
    }
    
    func respondioBien() -> Bool{
        if let respuestaDelUsuario = EntradaTextField.text{
            if(respuestaDelUsuario == respuestaCorrecta){
                return true
            }
        }
        return false
    }
    
    func mostrarCalificacion() {
        if(respondioBien()){
             CalificacionImagenView.image = #imageLiteral(resourceName: "correcto")
        }else{
             CalificacionImagenView.image = #imageLiteral(resourceName: "equivocado")
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.AlturaDeImagenConstraint.constant = 64
            self.CalificacionImagenView.alpha = 1
            self.RevisarButton.setTitle(NSLocalizedString("Next", comment: ""), for: .normal)
            self.yaFueRevisado = true
        })
    }
    
    func siguienteEjercicio() {
        if let siguienteE = ejercicios.first{
            let storyBoard: UIStoryboard = (self.navigationController?.storyboard)!
            var siguienteViewController: UIViewController?
            switch siguienteE.tipo! {
            case "Voz":
                let eVoz = storyBoard.instantiateViewController(withIdentifier: "EjercicioVozVC") as! EjercicioVozVC
                eVoz.color = self.color
                eVoz.ejercicios = ejercicios
                siguienteViewController = eVoz
            case "Opcion multiple":
                let eOpMul = storyBoard.instantiateViewController(withIdentifier: "EjercicioOpMulVC") as! EjercicioOpMulVC
                eOpMul.color = self.color
                eOpMul.Ejercicios = ejercicios
                siguienteViewController = eOpMul
            case "Ordenar oracion":
                let eOrOr = storyBoard.instantiateViewController(withIdentifier: "EjercicioOrdenarVC") as! EjercicioOrdenarVC
                eOrOr.color = self.color
                eOrOr.ejercicios = ejercicios
                siguienteViewController = eOrOr
            case "Escritura":
                let eEs = storyBoard.instantiateViewController(withIdentifier: "EjercicioEscrituraVC") as! EjercicioEscrituraVC
                eEs.color = self.color
                eEs.ejercicios = ejercicios
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
    
    // MARK:- Voz
    
    func iniciarGrabacion(){
        if tareaDeReconocimiento != nil {
            tareaDeReconocimiento?.cancel()
            tareaDeReconocimiento = nil
        }
        let sesionDeAudio = AVAudioSession.sharedInstance()
        do {
            try sesionDeAudio.setCategory(AVAudioSessionCategoryRecord)
            try sesionDeAudio.setMode(AVAudioSessionModeMeasurement)
            try sesionDeAudio.setActive(true, with: .notifyOthersOnDeactivation)
        } catch{
            print("Error al ponerle las propiedades a la sesion de audio")
        }
        solicitudDeReconocimiento = SFSpeechAudioBufferRecognitionRequest()
        let nodoEntrada = MotorDeAudio.inputNode
        
        solicitudDeReconocimiento!.shouldReportPartialResults = true
        tareaDeReconocimiento = SpeechRecognizer?.recognitionTask(with: solicitudDeReconocimiento!, resultHandler: { (resultado, error) in
            var yaTermino = false
            if resultado != nil{
                self.EntradaTextField.text = resultado?.bestTranscription.formattedString
                yaTermino = (resultado?.isFinal)!
            }
            
            if error != nil || yaTermino || self.respondioBien(){
                self.detenerGrabacion()
                nodoEntrada.removeTap(onBus: 0)
                self.mostrarCalificacion()
                
            }
            
        })
        let formatoGrabacion = nodoEntrada.outputFormat(forBus: 0)
        nodoEntrada.installTap(onBus: 0, bufferSize: 1024, format: formatoGrabacion, block: {(buffer, when) in
            self.solicitudDeReconocimiento?.append(buffer)
        })
        
        MotorDeAudio.prepare()
        do {
            try 	MotorDeAudio.start()
            self.IndicadorDeActividad.startAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                self.IndicadorDeActividad.alpha = 1
            })
        }catch{
            print("no se pudo arrancar el motor de audio debido a un error")
        }
    }
    
    func detenerGrabacion() {
        MotorDeAudio.stop()
        solicitudDeReconocimiento = nil
        tareaDeReconocimiento  = nil
        MicrofonoButton.isEnabled = true
        IndicadorDeActividad.alpha = 0
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available{
            MicrofonoButton.isEnabled = true
        }
        else {
            MicrofonoButton.isEnabled = false
        }
    }
    
    func revisarConexion() {
        if (currentReachabilityStatus == .notReachable) {
            let titulo = NSLocalizedString("No Internet connection detected", comment: "")
            let mensaje = NSLocalizedString("Voice exercises requiere an Internet connection.", comment: "")
            
            let alerta = UIAlertController.init(title: titulo, message: mensaje, preferredStyle: .alert)
            alerta.addAction(UIAlertAction.init(title: NSLocalizedString("Dismiss", comment:""), style: .default, handler: nil))
            MuteMicrofono(self)
            self.present(alerta, animated: true)
        }
    }
}
