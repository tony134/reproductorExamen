import controlP5.*;
import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;
import ddf.minim.analysis.*;
import javax.swing.*;
//elastic
import org.elasticsearch.action.admin.indices.exists.indices.IndicesExistsResponse;
import org.elasticsearch.client.Client;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.node.Node;
import org.elasticsearch.node.NodeBuilder;
import org.elasticsearch.action.ActionRequest;

Client client;
Node node;


//fin elastic


Minim cadena;
ControlP5 play, stop, pause, volu, select, baja, alta, media;
ControlP5 cp5;
AudioPlayer cancion;
AudioMetaData meta;
HighPassSP hpf;
Slider prog;
LowPassFS lpf;
BandPass bpf;
FFT fft;
String title = "";
String author = "";
long tiempo ;
int progressBarAlpha = 150; // bar
int soundVisionAlpha = 50;  // visual;
color grey = #3D3B38;
boolean fileLoaded = false;
float valor= 100, temp = 100;
Knob myKnobA;
Knob myKnobB;
Knob myKnobC;


JFileChooser fileSelector;

void setup() {

  //elastic





  //elastic fin




  fileSelector = new JFileChooser();
  // meta = cancion.getMetaData();
  size(400, 400);
  noStroke();
  play = new ControlP5(this);
  play.addButton("play")
    .setValue(0)
    .setPosition(150, 320)
    .setSize(50, 50);
  stop = new ControlP5(this);
  stop.addButton("stop")
    .setValue(0)
    .setPosition(200, 320)
    .setSize(50, 50);
  pause = new ControlP5(this);
  pause.addButton("pause")
    .setValue(0)
    .setPosition(250, 320)
    .setSize(50, 50);
  volu = new ControlP5(this);
  volu.addKnob("vol")
    .setRange(0, 100)
    .setValue(100)
    .setPosition(50, 310)
    .setRadius(30)
    .setNumberOfTickMarks(10)
    .setTickMarkLength(4)
    .snapToTickMarks(true)
    .setColorForeground(color(255))
    .setColorBackground(color(0, 160, 100))
    .setColorActive(color(255, 255, 0))
    .setDragDirection(Knob.HORIZONTAL);

  

  select = new ControlP5(this);
  select.addButton("select")

    .setPosition(300, 320 )
    .setSize(50, 50);

  cadena = new Minim(this);
  cancion = cadena.loadFile("", 1024);
  
  

  
  
  }

void efect() {

  fft = new FFT(cancion.bufferSize(), cancion.sampleRate());
  fft.logAverages(22, 3);
  bpf = new BandPass(100, 100, cancion.sampleRate());
  cancion.addEffect(bpf);
  lpf = new LowPassFS(100, cancion.sampleRate());
  //cancion.addEffect(lpf);
 // hpf = new HighPassSP(1000, cancion.sampleRate());
  //cancion.addEffect(hpf);
}

void funcionBienBergas(){
  baja = new ControlP5(this);
  myKnobA =  baja.addKnob("baja")
    .setRange(100, 10000)
    .setValue(temp)
    .setPosition(90, 230)
    .setRadius(30)
    .setNumberOfTickMarks(10)
    .setTickMarkLength(4)
    .snapToTickMarks(true)
    .setColorForeground(color(255))
    .setColorBackground(color(0, 160, 100))
    .setColorActive(color(255, 255, 0))
    .setDragDirection(Knob.HORIZONTAL);
    
  alta = new ControlP5(this);
  myKnobB = alta.addKnob("alta")
    .setRange(0, 100)
    .setValue(220)
    .setPosition(170, 230)
    .setRadius(30)
    .setNumberOfTickMarks(10)
    .setTickMarkLength(4)
    .snapToTickMarks(true)
    .setColorForeground(color(255))
    .setColorBackground(color(0, 160, 100))
    .setColorActive(color(255, 255, 0))
    .setDragDirection(Knob.HORIZONTAL);

  media = new ControlP5(this);
  myKnobC =  media.addKnob("media")
    .setRange(0, 100)
    .setValue(220)
    .setPosition(250, 230)
    .setRadius(30)
    .setNumberOfTickMarks(10)
    .setTickMarkLength(4)
    .snapToTickMarks(true)
    .setColorForeground(color(255))
    .setColorBackground(color(0, 160, 100))
    .setColorActive(color(255, 255, 0))
    .setDragDirection(Knob.HORIZONTAL);
  
  myKnobA.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {  
      valor = int(theEvent.getController().getValue());
     temp = valor;
     println("bpf: "+valor);
    bpf.setFreq(valor);
   bpf.setBandWidth(valor);
    }
  }
  );
  myKnobB.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {  
     valor = int(theEvent.getController().getValue());
     println("hpf: "+valor);
     //hpf.setFreq(valor);
    }
  }
  );
  
  
  myKnobC.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {  
     valor = int(theEvent.getController().getValue());
     println("lpf: "+valor);
    lpf.setFreq(valor);
    }
  }
  );
}

void draw() {

  background(0);
if (frameCount % 30 == 0) {
    thread("moveBar");
  }

  if (fileLoaded) {
    soundVision();                  //Calls visualizer function
    textSize(21);
    textAlign(CENTER);
    text(title, width/2, height/2.5);
    text(author, width/2, (height/2.5)+30);
  }
}


public void play() {
  cancion.play();
  cancion.loop();
  println("play");
}

public void stop() {
  cancion.pause();
  cancion.rewind();
  println("stop");
}

public void pause() {
  cancion.pause();
  println("pause");
}

void moveBar(){
  prog.setValue(cancion.position());
}

public void select() {
  selectInput("Select a file to process:", "fileSelected");
}
void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {

    cancion = cadena.loadFile(selection.getAbsolutePath(), 1024);
    efect();
    println("User selected " + selection.getAbsolutePath());
    meta = cancion.getMetaData();
    fft = new FFT(cancion.bufferSize(), cancion.sampleRate());
    fileLoaded = true;
    title = meta.title();
    author = meta.author();
    tiempo = meta.length();
    funcionBienBergas();
    cp5 = new ControlP5(repro.this);
  prog = cp5.addSlider("prog")
    .setPosition(0,10)
    .setLabel("")
    .setValueLabel("")
    .setSize(400, 20)
    .setRange(0, cancion.length())
    .setValue(128);
    
    prog.addCallback(new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {  
      if(theEvent.getAction()==ControlP5.ACTION_PRESSED){
          //println(prog.isUpdate());
          float sliderValue = 0;
          sliderValue = theEvent.getController().getValue();
         // println(prog.getValue());
          println("Event fired");
          println(sliderValue);
          cancion.rewind();
          cancion.skip((int)sliderValue);
          cancion.play();
          prog.setValue(sliderValue);
         // prog.scrolled((int)theEvent.getController().getValue());
      }
    }
  }
  );
  }
}



void controlEvent (ControlEvent evento) // se activa el evento
{


  if (evento.isFrom(volu.getController("vol"))) {
    float valor=40; 
    String nombre = evento.getController().getName(); // recoje el nombre del slider y lo convierte en String
    valor = int(evento.getController().getValue()); // recoje el valor del slider y lo convierte en entero
    println(nombre + ":" + valor); // imprime por pantalla el nombre y el valor

    valor= valor-41;

    cancion.setGain(valor);
  }
  if (evento.isFrom(baja.getController("baja"))) {
  }
}

void soundVision() {
  fft.forward( cancion.mix );

  fill(#45ADA8, soundVisionAlpha);
  stroke(grey);
  strokeWeight(1);


  if (progressBarAlpha<200 && soundVisionAlpha<255) {
    soundVisionAlpha+=3;
  } else if (soundVisionAlpha>50) {
    soundVisionAlpha-=40;
  }

  for (int i = 0; i < fft.specSize (); i+=5) {

    // draw the line for frequency band i, scaling it up a bit so we can see it
    colorMode(HSB);


    stroke(i, 255, 255);

    line( i, (height/3), i, (height/3) - fft.getBand(i)*8 );
  }
}