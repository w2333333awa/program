PFont font;
float maxPath = 500;

boolean running = false;
boolean g = true;
boolean tar = false;
boolean inform = true;
boolean tip = true;
boolean vline = false;
boolean J = false;

float G = 0.5f;

float bs = 1;

ArrayList<String> message = new ArrayList<String>();
ArrayList<Body> bodys = new ArrayList<Body>();

float[][] mass;
color[]col;

int startBodyCount = 1000;
PVector startBodyMass = new PVector(10, 50);
float startBodySpeed = .5;
float speed = 1;

Body max;
Body target;

void setup()
{
    
    registerMethod("post", this);
    frameRate(144);
    size(1600, 900, P3D);
    font = loadFont("Dialog.plain-24.vlw");
    
    colorMode(HSB,360,100,100);
    
    max = new Body(0, 0, 0, 0, 0, 0, -1);
    target = max;
    
    for (int i = 0; i < startBodyCount; i++)
    {
        bodys.add(new Body(random(startBodyMass.x, startBodyMass.y), //mass
                           random(2*width),                          //x
                           random(2*height),                         //y
                           random(-startBodySpeed, startBodySpeed),  //vx
                           random(-startBodySpeed, startBodySpeed),  //vy
                           random(-0.1, 0.1),                        //angvel
                           i));                                      //id
    }
    
    
    //add a star
    
    //bodys.add(new Body(100000, width, height, 0, 0, 0)); //创建星体
    
    //bodys.add(new Body(700, width / 2 + 400, height / 2, 0, 0, 0.1, 1));
    //bodys.add(new Body(700, width / 2 + 430, height / 2, 0, 0, 0, 2));
    /*for (int i = 0; i < 150; i++)
    {
      Float x =random(2*width);
      Float y =random(2*height);
      bodys.add(new Body(1e-10, x, y, (5000000f*sin(atan2(y-height,x-width))*random(0.9, 1)) / (x*x+y*y), (5000000f*cos(atan2(y-height,x-width))*random(0.9, 1)) / (x*x+y*y), i+3));
    }*/
    
    
    noLoop();
}

void draw()
{
    colorMode(HSB,360,100,100);
    background(0);
    if (!tar)
    {
      target = max;
    }
    translate(-target.pos.x*bs + (width / 2), -target.pos.y*bs + (height / 2));
    
    
    
    
    
    textAlign(LEFT);
    textFont(font, 12);
    //show body
    
    for (int i = 0; i < bodys.size(); i++)
    {
        Body b = bodys.get(i);
        if(b.pos.x*bs+b.r*bs > target.pos.x*bs-width/2 &&
           b.pos.x*bs-b.r*bs < target.pos.x*bs+width/2 &&
           
           b.pos.y*bs+b.r*bs > target.pos.y*bs-height/2 &&
           b.pos.y*bs-b.r*bs < target.pos.y*bs+height/2)
        {
          strokeWeight(1);
          if(g)b.ShowPath(); //show path
          noStroke();
          b.Show();
          if(J)b.ShowJ();
          
        }
        else{continue;}
    }
    
    
    if (!tar)
    {
      target = max;
    }
    translate(target.pos.x*bs - width / 2, target.pos.y*bs - height / 2);
    textAlign(LEFT);
    textFont(font, 16);
    //show fps
    fill(#00FF00);
    text("FPS: " + (int)frameRate, 10, 20);
    
    //show body count
    fill(360);
    text("Body Count: " + bodys.size() + "    Magnification: " + bs + "    target: " + target.id + "-" + tar + "   vline: " + vline + "   speed: " + speed, 10, 40);
    text("==========================================================", 10, 50);
    
    e();
    //show body info
    for (int i = 0; i < bodys.size(); i++)
    {
        float[] a = mass[mass.length-i-1];
        
        //高亮
        fill(360);
        text(i+1 + ".Body #" + (int)a[0] + ": mass" + a[1],10,(i + 1) * 20 + 45);
        
        fill(col[(int)a[0]]);
        //--
        text(i+1 + ".Body #" + (int)a[0] + ": mass" + a[1], 10, (i + 1) * 20 + 45);
    }
    
    textAlign(RIGHT);
    for (int i = 0; i < message.size(); i++)
    {
      fill(360);
      text(message.get(i), width - 10, height - (message.size()-i+1)*20);
    }
    
    textAlign(LEFT);
    if (inform)
    {
      text("id: #" + target.id, width - 300, 20);
      text("mass: " + target.mass, width - 300, 40);
      text("position: x:" + target.pos.x, width - 300, 60);
        text("y:" + target.pos.y, width - 237.5, 80);
      text("velocity: size:" + target.vel.mag(), width - 300, 100);
        text("direction:" + target.vel.heading() / TWO_PI * 360 + "°", width - 237.5, 120);
      text("radius: " + target.r, width - 300, 140);
    }
    textAlign(CENTER);
    if (tip)
    {
      text("Zoom: o-:q | O+:e" + "  Stop/Setup: p" + "  TargetSelection: t" + "  Trajectory: g" + "  Information: i" + "  KeyHints: b" + "  SpeedLine: v", width/2, 20);
    }
    
}

void keyPressed()
{
    if (key == 'p' || key == 'P'){if (running){running = false;noLoop();}else{running = true;loop();}}
    if (key == 't' || key == 'T'){if (tar){tar = false;}else{tar = true;}}
    if (key == 'g' || key == 'G'){if (g){g = false;}else{g = true;}}
    if (key == 'i' || key == 'I'){if (inform){inform = false;}else{inform = true;}}
    if (key == 'b' || key == 'B'){if (tip){tip = false;}else{tip = true;}}
    if (key == 'v' || key == 'V') {if (vline){vline = false;}else{vline = true;}}
    if (key == 'q' || key == 'Q'){bs *= 1.1;}
    if (key == 'e' || key == 'E'){bs /= 1.1;}
    if (key == 'y' || key == 'Y'){speed *= 1.5;}
    if (key == 'h' || key == 'H'){speed /= 1.5;}
    if (key == 'j' || key == 'J'){if (J){J = false;}else{J = true;}}
}

void e() {
  mass = new float[bodys.size()][2];
  col = new color[startBodyCount];
  
  for (int i = 0; i < bodys.size(); i++) {
    mass[i][0] = bodys.get(i).id;
    mass[i][1] = bodys.get(i).mass;
    col[bodys.get(i).id] = bodys.get(i).col;
  }
  paixu(mass, 1);
}

void paixu(float[][] s, int n) {
  for(int v = 0; v < s.length; v++) {
    for(int i = 0; i < s.length-1; i++) {
      float[] a = {s[i][0],s[i][n]};
      float[] b = {s[i+1][0],s[i+1][n]};
      
      if (a[n] > b[n]) {
        s[i] = b;
        s[i+1] = a;
      }
    }
  }
}


void post() 
{
    for (int i = 0; i < bodys.size(); i++)
    {
      Body b = bodys.get(i);
      b.Attract();
      b.AddPath();
    }
    
    for (int i = 0; i < bodys.size(); i++)
    {
      Body b = bodys.get(i);
      b.Update();
    }
}
