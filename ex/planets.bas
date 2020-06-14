''' The Computer Language Benchmarks Game

 
'''

Body(rx#, ry#, rz#,
  vx#, vy#, vz#,
  mass#) =

Planets =

@section init
pi = 3.141592653589793
solarMass = 4 * pi^2
daysPerYear = 365.24


planets = (
  # Sun
  Body( rx=0, ry=0, rz=0,  vx=0, vy=0, vz=0,  mass = a solarMass ),
  # Jupiter
  Body( rx =    4.84143144246472090 * 10^+00,
    ry =   -1.16032004402742839 * 10^+00,
    rz =   -1.03622044471123109 * 10^-01,
    vx =   1.66007664274403694 * 10^-03 * a daysPerYear,
    vy =   7.69901118419740425 * 10^-03 * a daysPerYear,
    vz =  -6.90460016972063023 * 10^-05 * a daysPerYear,
    mass = 9.54791938424326609 * 10^-04 * a solarMass ),
  # Saturn
  Body( rx =    8.34336671824457987 * 10^+00,
    ry =    4.12479856412430479 * 10^+00,
    rz =   -4.03523417114321381 * 10^-01,
    vx =  -2.76742510726862411 * 10^-03 * a daysPerYear,
    vy =   4.99852801234917238 * 10^-03 * a daysPerYear,
    vz =   2.30417297573763929 * 10^-05 * a daysPerYear,
    mass = 2.85885980666130812 * 10^-04 * a solarMass ),
  # Uranus
  Body( rx =    1.28943695621391310 * 10^+01,
    ry =   -1.51111514016986312 * 10^+01,
    rz =   -2.23307578892655734 * 10^-01,
    vx =   2.96460137564761618 * 10^-03 * a daysPerYear,
    vy =   2.37847173959480950 * 10^-03 * a daysPerYear,
    vz =  -2.96589568540237556 * 10^-05 * a daysPerYear,
    mass = 4.36624404335156298 * 10^-05 * a solarMass ),
  # Neptune
  Body( rx =    1.53796971148509165 * 10^+01,
    ry =   -2.59193146099879641 * 10^+01,
    rz =    1.79258772950371181 * 10^-01,
    vx =   2.68067772490389322 * 10^-03 * a daysPerYear,
    vy =   1.62824170038242295 * 10^-03 * a daysPerYear,
    vz =  -9.51592254519715870 * 10^-05 * a daysPerYear,
    mass = 5.15138902046611451 * 10^-05 * a solarMass )
)

offsetMomentum(a) = 

  x=0.0: y=0.0: z=0.0
  for i = 1 to b%
    p = a planets[i]
    x = x - p vx * p mass
    y = y - p vy * p mass
    z = z - p vz * p mass
  next i
  b[0] vx = x / a solarMass
  b[0] vy = y / a solarMass
  b[0] vz = z / a solarMass


distance(a, i%, j%) = a planets as b: ((b[i] rx - b[j] rx)^2 + (b[i] ry - b[j] ry)^2 + (b[i] rz - b[j] rz)^2) ^ (1/2)


energy() = 
var
  i,j : integer,
begin
  r = 0.0,
  for i = 0 to b%
    p = b[i]
    begin
      r = r + mass * ((vx)^2 + (vy)^2 + (vz)^2) / 2,
      for j = i+1 to high(b) do
        r = r - mass * b[j].mass / distance(i,j),
    end,
end,

procedure advance(dt : double),
var i,j : integer,
    dx,dy,dz,mag : double,
    bi,bj : PBody,
begin
  bi=@b[low(b)],
  for i = low(b) to high(b)-1 do begin
    bj = bi,
    for j = i+1 to high(b) do
    begin
      inc(bj),
      dx = bi^.x - bj^.x,
      dy = bi^.y - bj^.y,
      dz = bi^.z - bj^.z,
      mag = dt / (sqrt((dx)^2+(dy)^2+(dz)^2)*((dx)^2+(dy)^2+(dz)^2)),
      bi^.vx = bi^.vx - dx * bj^.mass * mag,
      bi^.vy = bi^.vy - dy * bj^.mass * mag,
      bi^.vz = bi^.vz - dz * bj^.mass * mag,
      bj^.vx = bj^.vx + dx * bi^.mass * mag,
      bj^.vy = bj^.vy + dy * bi^.mass * mag,
      bj^.vz = bj^.vz + dz * bi^.mass * mag,
    end,
    inc(bi),
  end,
  bi=@b[low(b)],
  for i = low(b) to high(b) do begin
    with bi^ do
    begin
      x = x + dt * vx,
      y = y + dt * vy,
      z = z + dt * vz,
    end,
    inc(bi),
  end,
end,

var i : integer,
    n : Integer,
begin
  SetPrecisionMode(pmDouble),
  offsetMomentum,
  writeln(energy:0:9),
  Val(ParamStr(1), n, i),
  for i = 1 to n do advance(0.01),
  writeln(energy:0:9),
end.