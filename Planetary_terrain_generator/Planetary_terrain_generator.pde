/*
by 2333333awa
lastest update: 2025/7/13
version: 1.2.1
Processing Python Source Code
Processing 4.4.4 for Windows
https://processing.org/download
*/


//Q-Zoom+ E-Zomm- F-NextMap R-LastMap 1~6-Map0~5 G-Regeneration I-Information
//LeftClick-Move Right-MoveLight

//This is changeable.

float noiseVal,GVal,HVal,Val,SVal,T,V;

float noiseS = 0.5;
float seaH = 0.7;
float K=0.2,J=-20.0;
boolean Done = false;

int typenum = 5;
String[] typenam = {"Height Map", "Color Map", "Temperature Map", "Normal map", "Slop Map", "Satellite Map"};

float R = 200;
int H = int(2*R);
int W = int(2*PI*R);

float[][] Height = new float[W][H];
float[][] Temperature = new float[W][H];
PVector[][] Normal = new PVector[W][H];
float[][] Slop = new float[W][H];

float[] HMaxMin = {-pow(2,32),pow(2,32)};
float[] TMaxMin = {-pow(2,32),pow(2,32)};
long Seed;

color[] BuffC = new color[W*H];



PVector pos = new PVector(0,0);
float scaling = 1;

PVector LightAng = new PVector(0,0);

void setup()
{
  noiseDetail(8,0.6);
  Seed = (int)random(-pow(2,31), pow(2,31));
  print("Seed:" + Seed + "\n");
  size(1256,400);
  createoff();
  create();
}
void draw()
{
  if(Done == false)
  {
    handoff(typenum);
    drawMap(typenam[typenum]);
  }
  if(typenum == 5){drawShadow();}
  drawWWL();
  drawCrossHair();
  drawText();
  if (mousePressed && (mouseButton == LEFT))
  {
    pos = pos.sub(new PVector(mouseX-W/2, mouseY-H/2));
    create();
  }
  if (mousePressed && (mouseButton == RIGHT))
  {
    float X,Y,ax,ay;
    X = ((float)mouseX/W*2-1)*PI;
    Y = -((float)mouseY/H*2-1);
    ay = atan2(Y,sqrt(1-Y*Y));
    ax = X;
    LightAng = new PVector(ax, ay);
  }
}

//Creat F---------------------------------------------------------------

void create()
{
  if(pos.y>0){pos.y=0;}
  if(pos.y*scaling-H*scaling<-H){pos.y=(-H*(1-scaling))/scaling;}
  if(pos.x*scaling>W){pos.x =(pos.x*scaling)%W;}
  if(pos.x*scaling<-W){pos.x = (pos.x*scaling)%W;}
  //print(H*scaling);
  //print(pos+"\n");
  HMaxMin[0] = -100;
  HMaxMin[1] = 100;
  TMaxMin[0] = -10000;
  TMaxMin[1] = 10000;
  createMap();
  createNorMap(10/scaling);
  Done = false;
}

void createMap()
{
  noiseSeed((int)Seed);
  float ax,ay,Gx,Gy,Gz,X,Y;
  for (int y=0; y<H; y++)
  {
    Y = -(((float)y-pos.y)*scaling/H*2-1);
    ay = atan2(Y,sqrt(1-Y*Y));
    for (int x=0; x<W; x++)
    {
      X = (((float)x-pos.x)*scaling/W*2-1)*PI;
      ax = X;
      
      Gx = cos(ax)*cos(ay);
      Gy = sin(ax)*cos(ay);
      Gz = sin(ay);
      noiseVal = noise((Gx+1)*noiseS,(Gy+1)*noiseS,(Gz+1)*noiseS);
      GVal = 2*noiseVal*noiseVal-seaH;
      
      if(GVal < 0)
        GVal = -pow(GVal*5,2)/15;
     
      //noiseDetail(1,0.5);
      noiseVal = noise((Gx+100)*noiseS*2,(Gy+100)*noiseS*2,(Gz+100)*noiseS*2);
      HVal = pow(1-abs(2*noiseVal-1)+0.01,8);
      
      noiseVal = noise((Gx+200)*noiseS,(Gy+200)*noiseS,(Gz+200)*noiseS);
      SVal = pow(1-abs(2*noiseVal-1)+0.01,8);
      
      Val = 0.3*GVal + 1.3*abs(GVal)*HVal - 1.1*abs(GVal)*SVal;
      //if(x>500 && x<700 && y>150 && y<250){Val=ax*ax+ay*ay;}
      
      T = cos(ay)*60+245;
      if(Val>=0){T -= Val*6*15;T = 275 + (T-275)*1.1;}
      
      Height[x][y] = Val;
      Temperature[x][y] = T;
      if (Val>HMaxMin[0]){HMaxMin[0] = Val;}  if (Val<HMaxMin[1]){HMaxMin[1] = Val;}
      if (T>TMaxMin[0]){TMaxMin[0] = T;}      if (T<TMaxMin[1]){TMaxMin[1] = T;}
    }
  }
}
void createNorMap(float S)
{
  float w,a,s,d,m,X,Y,ax,ay;
  PVector dGN;
  PVector N;
  for (int y=0;y<H;y++)
  {
    for (int x=0;x<W;x++)
    {
      m = Height[x][y];
      if(y == 0)
      {
        w = m;
        s = Height[x][y+1];
      }
      else if(y == H-1)
      {
        w = Height[x][y-1];
        s = m;
      }
      else
      {
        w = Height[x][y-1];
        s = Height[x][y+1];
      }
      if(x == 0)
      {
        a = Height[W-1][y];
        d = Height[x+1][y];
      }
      else if(x == W-1)
      {
        a = Height[x-1][y];
        d = Height[0][y];
      }
      else
      {
        a = Height[x-1][y];
        d = Height[x+1][y];
      }
      Y = -(((float)y-pos.y)*scaling/H*2-1);
      ay = atan2(Y,sqrt(1-Y*Y));
      X = (((float)x-pos.x)*scaling/W*2-1)*PI;
      ax = X;
      
      dGN = new PVector(sin(ax)*cos(ay), sin(ay), cos(ay)*cos(ax));
      
      N = new PVector(0,0,1);
      if (m > 0)
        N = new PVector(2*cos(ay),0,S*(d-a)).cross(new PVector(0,2,S*(w-s))).normalize();
      
      Normal[x][y] = N;//dGN.normalize();
      Slop[x][y] = sqrt(pow(S*(d-a)/(2*cos(ay)), 2)+pow(S*(w-s)/2, 2));
    }
  }
}
void Regeneration(long seed)
{
  print("Seed:" + seed + "\n");
  noiseSeed(seed);
  createoff();
  create();
}

//Draw F-------------------------------------------------------------------------------------------------

void drawMap(String type)
{
  loadPixels();
  background(255);
  stroke(#FF00FF);
  color Color = color(0,0,0);
  for (int y=0;y<H;y++)
  {
    for (int x=0;x<W;x++)
    {
      Val = Height[x][y];
      T = Temperature[x][y];
      V = Slop[x][y];
      
      if (typenum == 0)
      {
        colorMode(RGB,255,255,255);
        Color = color(map(Val, HMaxMin[1], HMaxMin[0], 0, 255));
        //stroke(map(Val, HMaxMin[1], HMaxMin[0], 0, 255));
      }
      else if (typenum == 1)
      {
        colorMode(RGB,255,255,255);
        if(Val >= 0.6){Color = color(#834009);}
        else if(Val >= 0.5){Color = color(#BC3F11);}
        else if(Val >= 0.4){Color = color(#FF0000);}
        else if(Val >= 0.3){Color = color(#FF6105);}
        else if(Val >= 0.2){Color = color(#FFBD05);}
        else if(Val >= 0.1){Color = color(#C4FF05);}
        else if(Val >= 0.0){Color = color(#04C902);}
        else if(Val >= -0.1){Color = color(#00DBFF);}
        else if(Val >= -0.2){Color = color(#007DFF);}
        else if(Val >= -0.3){Color = color(#031DFF);}
        else {/*stroke(#090F48);*/Color = color(#090F48);}
        if(T<273.15)
          {
            if(Val>=0 && V<0.25) {if(T<257.13){Color = color(#FFFFFF);}else{}Color = color(#C9C99A);}
            else if(Val > -0.02 && Val<0){Color = color(#C1F6FF);}
          }
      }
      else if (typenum == 2)
      {
        colorMode(HSB,360,100,100);
        Color = color(map(T,TMaxMin[1],TMaxMin[0],240,0),100,100);
      }
      else if(typenum == 3)
      {
        colorMode(RGB,255,255,255);
        Color = color(255*Normal[x][y].x, 255*Normal[x][y].y, 255*Normal[x][y].z);
      }
      else if(typenum == 4)
      {
        colorMode(RGB,255,255,255);
        Color = color(map(Slop[x][y],0,1,0,255));
      }
      else if(typenum == 5)
      {
        if(Val<0)
        {
          Color = color(150 / (1-Val*15), 203 / (1-Val*7.6), 255 / (1-Val*4));
        }
        else
        {
          Color = color(#B49A6F); //Stone
          
          if(Val>=0 && V<0.2) {
              if(T>257.13){
                Color = color(#C9C99A); //FrozenSoil
              }
            }
          if(Val > 0.09)
          {
            Color = LinearlyC(#B49A6F, #645F44, min(1, (Val-0.09)/0.02 + (V-0.07)/0.09));
            if(Val > 0.11 && V>0.1)
            {
              Color = color(#645F44);
            } //DarkStone
          }
          if(V<0.04 && Val>0.01 && T>263 && T <295)
          {
            Color = color(#186007); //Plant
          }
          else if(V<0.08 && Val>0 && T>273 && T <305)
          {
            Color = LinearlyC(Color, #55711A, 0.3);
            if (Val*15 + T <307 && V < 0.06)
              Color = color(#55711A); //Grass
          }
          else if(V<0.04 && Val>0 && T>293 && T <315)
          {
            Color = LinearlyC(Color, #778616, 0.5);
            if (Val*103 + T <320 && Val>0.001 && V < 0.03)
              Color = color(#778616); //Hot Grass
          }
          if(T>300 && V<0.04 && Val>0.1){
            Color = color(#CEB151); //Sand
          }
          if(T<273.15)
          {
            if(Val>=0 && V<0.2) {
              if(T<257.13){
                Color = color(255); //Snow
              }
            }
            else if(Val > -0.02 && Val<0){
              Color = color(#C1F6FF); //Ice
            }
          }
        }
      }
      
      //point(x,y);
      pixels[y*width+x] = Color;
    }
  }
  updatePixels();
  loadPixels();
  for (int i=0;i<W*H;i++)
  {
    BuffC[i] = pixels[i];
  }
  Done = true;
}

void drawCrossHair()
{
  stroke(#FFFF00);
  line(W/2-10,H/2,W/2+10,H/2);
  line(W/2,H/2-10,W/2,H/2+10);
}

void drawText()
{
  if (typenum == 0)
  {
    fill(#FF00FF);
    textSize(16);
    textAlign(LEFT);
    text(float(int((HMaxMin[1])*100))/100*15 + "km  -  " + float(int((HMaxMin[0])*100))/100*15 + "km", 15, H-20);
  }
  else if (typenum == 1)
  {
  }
  else if (typenum == 2)
  {
    fill(#FF00FF);
    textSize(16);
    textAlign(LEFT);
    text((float)((int)((TMaxMin[1]-273.15)*10))/10 + "°C  -  " + (float)((int)((TMaxMin[0]-273.15)*10))/10 + "°C", 15, H-20);
  }
  else if(typenum == 3)
  {
  }
  else if(typenum == 4)
  {
  }
  else if(typenum == 5)
  {
  }
}

void drawWWL()
{
  if(typenum != 3)
  {
    stroke(#FF0000);
    line(0 +pos.x, H/scaling/2 +pos.y, W/scaling +pos.x, H/scaling/2 +pos.y);
    line(W/scaling/2 +pos.x, H/scaling +pos.y, W/scaling/2 +pos.x, 0 +pos.y);
    line(0 +pos.x, H/scaling +pos.y, 0 +pos.x, 0 +pos.y);
    line(W/scaling +pos.x, H/scaling +pos.y, W/scaling +pos.x, 0 +pos.y);
    line(W/scaling/4 +pos.x, H/scaling +pos.y, W/scaling/4 +pos.x, 0 +pos.y);
    line(3*W/scaling/4 +pos.x, H/scaling +pos.y, 3*W/scaling/4 +pos.x, 0 +pos.y);
  }
}


void drawShadow()
{
  colorMode(RGB,255,255,255);
  loadPixels();
  
  float ax,ay;
  ax = LightAng.x;
  ay = LightAng.y;
  
  for (int y=0;y<H;y++)
  {
    for (int x=0;x<W;x++)
    {
      PVector N = Normal[x][y];
      
      float d = N.normalize().dot((new PVector(sin(ax)*cos(ay),sin(ay),cos(ay)*cos(ax))).mult(1))+0.1;
      
      if(Height[x][y] < 0)
      {
        d = pow(d , 2.1)+0.1;
      }
      if(Height[x][y] > 0)
      {
        d = pow(d , 0.9);
      }
      color c = BuffC[y*width+x];
      pixels[y*width+x] = color(Blend(d*0.83+0.15,red(c),2), Blend(d*0.97,green(c),2), Blend(d*1.2-0.15,blue(c),2));
    }
  }
  updatePixels();
}


//Other F------------------------------------------------------------------------------------------------

float Blend(float A, float B, int type)
{
  float a = A/255;
  float b = B/255;
  if(a<0) a=0; if(a>1) a=1;
  if(b<0) b=0; if(b>1) b=1;
  
  if(type==0){ return 255*(1-(1-b)/a);}//Burn
  else if(type==1)
  {
    if(B<=0.5) //柔光
      return 255.0*(2*a*b+a*a*(1-2*b));
    else if(B>0.5)
      return 255.0*(2*a*(1-b)+(2*b-1)*sqrt(a));
    else
      return 0;
  }
  else if(type==2){return A*B;}
  else {return 0;}
}
color LinearlyC(color CA, color CB, float k)
{
  colorMode(RGB,255,255,255);
  return color(red(CA) + k*(red(CB) - red(CA)), green(CA) + k*(green(CB) - green(CA)), blue(CA) + k*(blue(CB) - blue(CA)));
}
float getH(int x, int y)
{
  return Height[x][y];
}
float getT(int x, int y)
{
  return Temperature[x][y];
}
float getS(int x, int y)
{
  return Slop[x][y];
}
PVector getN(int x, int y)
{
  return Normal[x][y];
}

void handoff(int tnum)
{
  colorMode(RGB,255,255,255);
  fill(#FF00FF);
  textSize(16);
  textAlign(LEFT);
  text(typenam[tnum] + " - " + tnum,5,20);
  text(W + "x" + H,5,40);
  textSize(48);
  fill(255);
  textAlign(CENTER,CENTER);
  text("Drawing...",W/2,H/2);
}
void createoff()
{
  background(0);
  colorMode(RGB,255,255,255);
  textSize(16);
  text(W + "x" + H,5,40);
  text("Seed: " + Seed,5,60);
  textSize(48);
  fill(255);
  textAlign(CENTER,CENTER);
  text("Creating...",W/2,H/2);
}

void keyPressed()
{
  if (key == 'f' || key == 'F')
  {
    typenum = (typenum+1)%typenam.length;
    Done = false;
    handoff(typenum);
  }
  if (key == 'r' || key == 'R')
  {
    typenum = (typenum+typenam.length-1)%typenam.length;
    Done = false;
    handoff(typenum);
  }
  if (key == 'g' || key == 'G')
  {
    Seed = (int)random(-pow(2,31), pow(2,31));
    createoff();
    Regeneration(Seed);
  }
  if (key == 's' || key == 'S')
  {
    save(typenam[typenum] + "-" + Seed + " " + hour() + "-" + minute() + "-" + second() + ".png");
    print("Save Picture: \"" + typenam[typenum] + "-" + Seed + " " + hour() + "-" + minute() + "-" + second() + ".png\"\n");
    //if(typenum==1 || typenum==5){save(typenam[typenum] + "-" + Seed + ".png");}
    //else if(typenum==0){saveBytes("HeightDat" + "-" + Seed + ".dat", dat);}
    /*else if(typenum==2){saveBytes("TemparetureDat" + "-" + Seed + ".dat", byte(Tempareture));}
    else if(typenum==3){saveBytes("NormalDat" + "-" + Seed + ".dat", byte(Normal));}
    else if(typenum==4){saveBytes("SlopDat" + "-" + Seed + ".dat", byte(Slop));}*/
  }
  if (key == '1'){typenum = 0;Done = false;handoff(typenum);}
  if (key == '2'){typenum = 1;Done = false;handoff(typenum);}
  if (key == '3'){typenum = 2;Done = false;handoff(typenum);}
  if (key == '4'){typenum = 3;Done = false;handoff(typenum);}
  if (key == '5'){typenum = 4;Done = false;handoff(typenum);}
  if (key == '6'){typenum = 5;Done = false;handoff(typenum);}
  
  if (key == 'q' || key == 'Q')
  {
    float v = scaling;
    scaling *=1.1;
    if(scaling > 1) scaling = 1;
    pos.x = (pos.x-W/2) / (scaling / v)+W/2;
    pos.y = (pos.y-H/2) / (scaling / v)+H/2;
    create();
  }
  if (key == 'e' || key == 'E')
  {
    float v = scaling;
    scaling /=1.1;
    if(scaling < 0.1) scaling = 0.1;
    pos.x = (pos.x-W/2) * (v / scaling)+W/2;
    pos.y = (pos.y-H/2) * (v / scaling)+H/2;
    create();
  }
  if (key == 'i' || key == 'I')
  {
    print("H:" + getH(mouseX, mouseY)*15 + "km\n"+
          "T:" + (getT(mouseX, mouseY)-273.15) + "°C\n"+
          "S:" + getS(mouseX, mouseY) + "\n");
  }
}
