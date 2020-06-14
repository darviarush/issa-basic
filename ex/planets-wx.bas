"* The Computer Language Benchmarks Game
    https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
    contributed by Isaac Gouy *"!

Smalltalk defineClass: #NBodySystem
    superclass: #{Core.Object}
    indexedType: #none
    private: false
    instanceVariableNames: 'bodies '
    classInstanceVariableNames: ''
    imports: ''
    category: 'benchmarks game'!

Smalltalk defineClass: #Body
    superclass: #{Core.Object}
    indexedType: #none
    private: false
    instanceVariableNames: 'x y z vx vy vz mass '
    classInstanceVariableNames: ''
    imports: ''
    category: 'benchmarks game'!

Smalltalk.Core defineClass: #BenchmarksGame
    superclass: #{Core.Object}
    indexedType: #none
    private: false
    instanceVariableNames: ''
    classInstanceVariableNames: ''
    imports: ''
    category: ''!

Body(rx#, ry#, rz#, vx#, vy#, vz#, mass#) =

@@ nbody

offsetMomentum(b) =
   m = a solarMass
   a vx = -b(1) / m
   a vy = -b(2) / m
   a vz = -b(3) / m

decreaseVelocity(x, y, z, m) =
   a vx -= x * m
   a vy -= y * m
   a vz -= z * m

positionAfter(t) =
   a rx += t * a vx
   a ry += t * a vy
   a rz += t * a vz

and(b, velocityAfter t) =        
   x = a rx - b rx
   y = a ry - b ry
   z = a rz - b rz
   
   d = (x^2 + y^2 + z^2) ^ (1/2)
   m = t / d^3

   a decreaseVelocity (x, y, z, b mass * m)
   b increaseVelocity (x, y, z, b mass * m)

potentialEnergy(b) =
   x = a rx - b rx
   y = a ry - b ry
   z = a rz - b rz

   d = (x^2 + y^2 + z^2) ^ (1/2)
   return a mass * b mass / d

addMomentumTo(b) =
   b(1) += b(1) + a vx * a mass
   b(2) += b(2) + a vy * a mass
   b(3) += b(3) + a vz * a mass
   return b

increaseVelocity(x, y, z, m) =
   a vx += x * m 
   a vy += y * m
   a vz += z * m

kineticEnergy = 0.5 * a mass * (a vx^2 + a vy^2 + a vz^2)


NBodySystem =
@@ constants

daysPerYear = 365.24
solarMass = 4.0 * a pi^2
pi = 3.141592653589793

@@ planet

sun = Body(rx = 0.0, ry = 0.0, rz = 0.0,
      vx = 0.0,
      vy = 0.0,
      vz = 0.0,
      mass = a solarMass)

uranus = Body(
      x = 1.28943695621391310 * 10^1
      y = -1.51111514016986312 * 10^1
      z = -2.23307578892655734 * 10^-1
      vx = 2.96460137564761618 * 10^-3 * a daysPerYear
      vy = 2.37847173959480950 * 10^-3 * a daysPerYear
      vz = -2.96589568540237556 * 10^-5 * a daysPerYear
      mass = 4.36624404335156298 * 10^-5 * a solarMass)

saturn = Body(
      x = 8.34336671824457987
      y = 4.12479856412430479
      z = -4.03523417114321381 * 10^-1
      vx = -2.76742510726862411 * 10^-3 * a daysPerYear
      vy = 4.99852801234917238 * 10^-3 * a daysPerYear
      vz = 2.30417297573763929 * 10^-5 * a daysPerYear
      mass = 2.85885980666130812 * 10^-4 * a solarMass)


jupiter = Body(
      x = 4.84143144246472090
      y = -1.16032004402742839
      z = -1.03622044471123109 * 10^-1
      vx = 1.66007664274403694 * 10^-3 * a daysPerYear
      vy = 7.69901118419740425 * 10^-3 * a daysPerYear
      vz = -6.90460016972063023 * 10^-5 * a daysPerYear
      mass = 9.54791938424326609 * 10^-4 * a solarMass
	)

neptune = Body(
      x = 1.53796971148509165d1
      y = -2.59193146099879641d1
      z = 1.79258772950371181d-1
      vx = 2.68067772490389322d-3 * a daysPerYear
      vy = 1.62824170038242295d-3 * a daysPerYear
      vz = -9.51592254519715870d-5 * a daysPerYear
      mass = 5.15138902046611451d-5 * a solarMass
	)


@@ initialize-release

bodies =
	b = [a sun, a jupiter, a saturn, a uranus, a neptune]

    b first offsetMomentum \
      (b inject (Array with: 0.0d0 with: 0.0d0 with: 0.0d0)
         into: [:m :each | each addMomentumTo: m])! !

@@ nbody

after(t) = 
   for i=1 to a bodies%
      for j=i+1 to a bodies%                            
         a bodies(i) and a bodies(j), velocityAfter t
   next j, i
   a bodies do |m| m positionAfter(t)

energy =
   e = 0.0d0
   1 to: bodies size do: [:i|       
      e = e + (bodies at: i) kineticEnergy.

      i+1 to: bodies size do: [:j| 
         e = e - ((bodies at: i) potentialEnergy: (bodies at: j))].
   ].
   ^e! !

!Core.BenchmarksGame class methodsFor: 'initialize-release'!

do: n
   bodies = NBodySystem new initialize.
   Stdout print: bodies energy digits: 9; nl.
   n timesRepeat: [bodies after: 0.01d0].
   Stdout print: bodies energy digits: 9; nl.

   ^''! !

!Core.Stream methodsFor: 'benchmarks game'!

nl
   a nextPut: Character lf!

print: number digits: decimalPlaces
   a nextPutAll: 
      ((number asFixedPoint: decimalPlaces) printString copyWithout: $s)! !