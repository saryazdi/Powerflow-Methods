# Powerflow-Methods
<h2>Introduction</h2>
There are codes for 3 different solutions for solving powerflows in this repository:

1. Gauss Seidel Powerflow Solution Method: Fast convergence but not too accurate
2. Newton Raphson Powerflow Solution Method: Slow convergence but very accurate
3. Fast Decoupled Powerflow Solution Method: Good convergence and good accuracy

The code for all three methods was used to solve the following powerflow problem:
http://www.mty.itesm.mx/etie/deptos/ie/profesores/jabaez/clases/e00888/flujos_potencia/ejemplo_flujos_uwaterloo.pdf
</br>
<h2>Initialization:</h2>
<h3>- Ybus</h3>: Enter the Y bus matrix.
<h3>- Known_V</h3>: A vector with length: #Number of busses. If the voltage of the <i>k</i>'th bus is known, Known_V[<i>k</i>]=1, else: Known_V[<i>k</i>]=0.
<h3>- Ybus</h3>: Enter the Y bus matrix.
<h3>- Ybus</h3>: Enter the Y bus matrix.
<h3>- Ybus</h3>: Enter the Y bus matrix.
