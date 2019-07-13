import processing.serial.*;
import controlP5.*;   
import java.io.PrintWriter;
import java.io.File;
import java.util.ArrayList;

ControlP5 cp5;

Serial myPort; 
String val;    
int[] data; 
double[] summed;
int draw_sum=0;
int sliderTicks = 100;
String filename = "";


double find_max(double[] input)
{
  double max = 0;
  for (int i = 0; i < input.length; i++) 
  {
    if (input[i] > max)
    {
      max = input[i];
    }            
  }
  return max;
}

void plotdata()
{

  double summed_max = (find_max(summed))/1750;

  background(0); 

  if (draw_sum !=0)
  {
    for (int i=0; i<summed.length-1; i++)
    {
      line(i, 0, i, 1000-(int)(summed[i] / summed_max ));
    }
  } else
  {

    for (int i=0; i<data.length-1; i++)
    {
      line(i, 0, i, 1000-data[i]);
    }
  }
  stroke(255);
}


void setup() 
{
  println(Serial.list());
    String portName = Serial.list()[0]; //This is the index into the serial list, if you only have one serial device the index is 0
  myPort = new Serial(this, portName, 115200);
  
  String[] fontList = PFont.list();
  printArray(fontList);
  
  cp5 = new ControlP5(this);
  PFont font = createFont("arial",20);

    
  cp5.addButton("UV")
    .setPosition(350,100)
    .setSize(100,80)
    .setFont(font);
    
  cp5.addButton("LED")
    .setPosition(350,200)
    .setSize(100,80)
    .setFont(font);
    
  cp5.addSlider("INTTIME")
    .setPosition(350,300)
    .setSize(20,200)
    .setRange(1,9)
    .setNumberOfTickMarks(9)
    .setFont(font);
    
  cp5.addButton("SAMPLE")
    .setPosition(350,600)
    .setSize(100,80)
    .setFont(font);
  
  cp5.addTextfield("Filename")
    .setPosition(350,700)
    .setSize(100,40)
    .setFont(font)
    .setFocus(true);
  
    
  summed = new double[288];

  for (int i = 0; i < 288; i++) 
  {
    summed[i] = 0;
  }

  size(700, 1000);
}

void draw()
{
 
  if ( myPort.available() > 0) 
  {  
    val = myPort.readStringUntil('\n');         // read it and store it in val
    if (val != null)
    {
      data = int(split(val, ',')); 

      for (int i = 0; i < data.length; i++) 
      {
        if (i<summed.length)
        {
          summed[i] +=  data[i];
        }
        //print(data[i]);
        // print(' ');
      }
      //  println( ' ');
      plotdata();
    }
  }
  fill(255,255,255);
  textSize(20);
  text("Control Panel", 340, 30);

}

void keyPressed() {

  if (key == 'c' ) 
  {
    for (int i = 0; i < summed.length; i++) 
    {
      summed[i] = 0;
    }
  } 
  else if (key == 't' ) 
  {
    if(draw_sum==1)
    {
      draw_sum = 0;
    }
    else
    {
      draw_sum = 1;
    }
  } 
  else if (key == UP){
    myPort.write('I');
  }
  else if (key == DOWN){
    myPort.write('D'); 
  }
  else 
  {
  }
}

void sampleFile(){ //Outputs text file with average values of each  
   String fname = cp5.get(Textfield.class, "Filename").getText();
   PrintWriter pw = createWriter(fname+".txt");
   pw.println("Tester");
   pw.println(fname+".txt");
   ArrayList<int[]> sampleValues = new ArrayList<int[]>();
   //setIntegrationTime();
   delay(250);
   for(int i = 0; i < 1000; i++){
      if ( myPort.available() > 0){  
         val = myPort.readStringUntil('\n');         // read it and store it in val
         if (val != null){
           data = int(split(val, ',')); 
         }
      }
      sampleValues.add(i, data);
      delay(5);
   }     
   double[] average = new double[288];
   for(int j = 0; j < 288; j++){
      for(int k = 0; k < 1000; k++){
          average[j] += sampleValues.get(k)[j];
      }
      average[j] = (double)average[j] / 1000;
      pw.println(average[j]);
   }
   pw.flush();
   pw.close();
}

void setIntegrationTime(){
    cp5.getController("INTTIME").setValue(69);
}

void SAMPLE(){
   //find_max(data);
   sampleFile(); 
}

void UV(){                   //Button to turn on UV
    myPort.write('U');
}

void LED(){                  //Button to turn on LED
  myPort.write('L');
}


void DELAY(){
  float delay = cp5.getController("INTTIME").getValue();
  myPort.write('b'+Integer.toString((int)delay)+'e');
}
