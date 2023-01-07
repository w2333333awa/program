class Body
{
    int id;
    float mass;
    float r;
    PVector pos;
    PVector vel;
    color col;
    
    color coll;
    
    ArrayList<PVector> path = new ArrayList<PVector>();
    
    Body(float mass, float x, float y, float vx, float vy, int id)
    {
        this.id = id;
        this.mass = mass;
        this.r = CalR(this.mass);
        this.pos = new PVector(x, y);
        this.vel = new PVector(vx, vy);
        this.col = color(random(0,360), random(0,100), random(25,100));
        this.coll = col;
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
        
        if (vline)
        {
          stroke(#E32525);
          line(pos.x * bs, pos.y * bs, pos.x * bs + cos(vel.heading()+PI) * -vel.mag() * bs  * 4, pos.y * bs + sin(vel.heading()+PI) * -vel.mag() * bs  * 4);
          
        }
        
        //fill(0);
        //text(id, pos.x, pos.y);
        
        fill(360);
        text(id + "(" + (int)mass + ")", pos.x*bs, pos.y*bs);
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
        pos.add(vel);
        
        if (tar)
        {
          PVector a = new PVector(this.pos.x * bs - (mouseX + target.pos.x * bs - width / 2), this.pos.y * bs - (mouseY + target.pos.y * bs - height / 2));
          col = coll;
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
            if (direction.mag() <= (this.r / 1) +(other.r / 1))
            {
                if (this.mass >= other.mass)
                {
                    this.vel = PVector.div(PVector.add(PVector.mult(this.vel, this.mass),
                                                       PVector.mult(other.vel, other.mass)),
                                                       this.mass + other.mass);
                    this.mass = this.mass + other.mass;
                    r = CalR(mass);
                    
                    if (target.id == other.id) target = this;
                    
                    message.add("#" + this.id + " devours " + "#" + other.id);
                    
                    if(message.size() > 10)
                    {
                      message.remove(0);
                    }
                    
                    bodys.remove(i);
                }
                continue;
            }
            
            if (new PVector(other.pos.x - max.pos.x, other.pos.y - max.pos.y).mag() > 40000 && other.vel.mag() > 2)
            {
              message.add("#" + other.id + " left this star system forever.");
              bodys.remove(i);
            }
            
            float forcePower = G * (this.mass * other.mass) / direction.magSq();
            PVector force = direction.normalize().mult(forcePower);
            
            if (direction.mag() <= (this.r / 1) +(other.r / 1)) {
              forcePower = direction.magSq() * (G * (this.mass * other.mass) / (this.r + other.r)) / (this.r + other.r);
            }
            other.vel.add((force.div(other.mass)).mult(1f / frameRate));
        }
        
    }
    
    void mouseHover()
    {
      this.col = coll + color(0,0,125);
      
      if (mousePressed && mouseButton == LEFT) mouseClicks();
    }
    void mouseClicks()
    {
      target = this;
    }
}