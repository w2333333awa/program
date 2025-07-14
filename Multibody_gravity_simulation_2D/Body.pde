class Body
{
    int id;
    float mass;
    float r;
    PVector pos;
    PVector vel;
    color col;
    
    float angle;
    float angvel;
    float T;
    float C;
    float Q;
    
    color coll;
    
    ArrayList<PVector> path = new ArrayList<PVector>();
    Body(float mass, float x, float y, float vx, float vy, float angvel, int id)
    {
        this.id = id;
        this.mass = mass;
        this.r = CalR(this.mass);
        this.pos = new PVector(x, y);
        this.vel = new PVector(vx, vy);
        this.angvel = angvel;
        this.col = color(random(0,360), random(0,100), random(25,100));
        this.coll = col;
        this.T = 270;
        this.C = 2000;
        this.Q = this.T*this.C*this.mass;
    }
    
    float CalR(float m)
    {
        //return sqrt(mass / PI);
        if (max == null || m >= max.mass)
        {
            max = this;
        }
        return pow(m / PI * (3f / 4f), 1f / 3f);
    }
    
    void Show()
    {
        noStroke();
        fill(col);
        ellipse(pos.x * bs, pos.y * bs, 2 * r * bs, 2 * r * bs);
        stroke(0);
        line(pos.x*bs, pos.y*bs, pos.x*bs + r*bs*cos(angle), pos.y*bs + r*bs*sin(angle));
        
        //if (vline)
        //{
        //  stroke(#E32525);
        //  line(pos.x * bs, pos.y * bs, pos.x * bs + cos(vel.heading()+PI) * -vel.mag() * bs  * 40, pos.y * bs + sin(vel.heading()+PI) * -vel.mag() * bs  * 40);
        //  
        //}
        
        fill(360);
        text(id, pos.x*bs, pos.y*bs);
        
        //fill(360);
        //text(id + "(" + (int)mass + ")", pos.x*bs, pos.y*bs);
    }
    
    void ShowPath()
    {
      stroke(col);
      for (int i = 0; i < path.size(); i++)
      {
          PVector a = path.get(i);
          PVector b;
          if (i + 1 == path.size())
          {
              b = pos;
          }
          else
          {
              b = path.get(i + 1);
              line(a.x*bs, a.y*bs, b.x*bs, b.y*bs);
          }
      }
    }
    
    void Update()
    {
        pos.add(new PVector(vel.x,vel.y).mult(speed));
        angle = (angle + angvel * speed)%(2*PI);
        
        if (tar)
        {
          PVector a = new PVector(this.pos.x * bs - (mouseX + target.pos.x * bs - width / 2), this.pos.y * bs - (mouseY + target.pos.y * bs - height / 2));
          if (this.r * bs < 20)
          {
            if (a.mag() <= 20)
            {
              mouseHover();
            }
          }
          else if (a.mag() <= this.r)
          {
            mouseHover();
          }
          else col = coll;
        }
        
    }
    
    void AddPath()
    {
        path.add(new PVector(pos.x, pos.y));
        if (path.size() > maxPath)
        {
            path.remove(0);
        }
    }
    
    void Attract()
    {
        for (int i = 0; i < bodys.size(); i++)
        {
            Body other = bodys.get(i);
            if (other == this)
            {
                continue;
            }
            PVector direction = new PVector(this.pos.x - other.pos.x, this.pos.y - other.pos.y);
            if (direction.mag() <= this.r + other.r)
            {
                if (this.mass >= other.mass)
                {
                    float dg = (other.r + this.r - direction.mag())/(other.r*2);
                    if(dg>1)dg=1;
                    if(dg<0)dg=0;
                    
                    float d_m = other.mass*dg;
                    this.mass = this.mass + d_m;
                    other.mass = other.mass - d_m;
                    
                    //PVector F = direction.normalize().mult(
                    //                                       (dg*(other.mass+this.mass)) * sqrt(this.vel.mag()*this.vel.mag() + other.vel.mag()*other.vel.mag()));
                    //this.vel.add(F.div(this.mass).mult(1f / frameRate * speed));
                    //other.vel.add(F.div(other.mass).mult(1f / frameRate * speed));
                    
                    
                    
                    this.vel = PVector.div(PVector.add(PVector.mult(this.vel, this.mass),
                                                         PVector.mult(other.vel, d_m)),
                                           this.mass + d_m);
                    other.vel = PVector.div(PVector.add(PVector.mult(this.vel, d_m),
                                                         PVector.mult(other.vel, other.mass)),
                                            this.mass + d_m);
                    //PVector odvel = (other.vel.sub(this.vel)).div((1+(60*dg/other.mass * (60f / frameRate * speed)))).add(this.vel);
                    //PVector tdvel = (this.vel.sub(other.vel)).div((1+(60*dg/this.mass * (60f / frameRate * speed)))).add(other.vel);
                    //other.vel = odvel;
                    //this.vel = tdvel;
                    
                    other.r = CalR(other.mass);
                    if(other.mass <= 0)
                    {
                      if (target.id == other.id) target = this;
                      message.add("#" + this.id + "(" + (int)this.mass + ") -[ " + "#" + other.id + "(" + (int)other.mass + ")");
                      if(message.size() > 10)
                      {
                        message.remove(0);
                      }
                      
                      this.mass = this.mass + other.mass;
                      bodys.remove(i);
                    }
                    
                    this.r = CalR(this.mass);
                }
                continue;
            }
            
            if (max.mass*5 > 5000) {
              if (new PVector(other.pos.x - max.pos.x, other.pos.y - max.pos.y).mag() > (max.mass*5 + this.mass*5) && other.vel.mag() > 2)
              {
                message.add("#" + other.id + " -");
                bodys.remove(i);
              }
            }
            float forcePower = G * (this.mass * other.mass) / direction.magSq();
            PVector force = direction.normalize().mult(forcePower);
            
            if (direction.mag() <= this.r) {
              forcePower = direction.mag() * (G * this.mass * other.mass) / pow(this.r, 3);
            }
            other.vel.add((force.div(other.mass)).mult(1f / frameRate * speed));
        }
        
    }
    
    void mouseHover()
    {
      col = coll + color(0,0,125);
      
      if (mousePressed && mouseButton == LEFT) mouseClicks();
    }
    void mouseClicks()
    {
      target = this;
    }
    
    void ShowJ(){
      stroke(this.col);
      noFill();
      ellipse(this.pos.x*bs,this.pos.y*bs,this.mass*10*bs,this.mass*10*bs);
    }
}
