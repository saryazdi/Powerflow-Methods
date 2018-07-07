# Powerflow-Methods
<h2>Introduction</h2>
There are codes for 3 different solutions for solving powerflows in this repository:

<b>1. Gauss Seidel Powerflow Solution</b> -> Fast convergence but not too accurate
<b>2. Newton Raphson Powerflow Solution</b> -> Slow convergence but very accurate
<b>3. Fast Decoupled Powerflow Solution</b> -> Good convergence and good accuracy

To know more about these solutions, you can check out this wikipedia page:
https://en.wikipedia.org/wiki/Power-flow_study

The code for all three methods was used to solve the following powerflow problem:
http://www.mty.itesm.mx/etie/deptos/ie/profesores/jabaez/clases/e00888/flujos_potencia/ejemplo_flujos_uwaterloo.pdf
</br>
<h2>Initialization</h2>
<h3>- Ybus</h3> Enter the Y bus matrix.

<h3>- Known_V</h3> A vector with length: #Number of busses. If the voltage magnitutde of the <i>k</i>'th bus is known, insert Known_V[<i>k</i>]=1, else insert Known_V[<i>k</i>]=0.

<h3>- Known_A</h3> A vector with length: #Number of busses. If the voltage phase of the <i>k</i>'th bus is known, insert Known_A[<i>k</i>]=1, else insert Known_A[<i>k</i>]=0.

<h3>- Known_P</h3> A vector with length: #Number of busses. If the real/active power of the <i>k</i>'th bus is known,insert Known_P[<i>k</i>]=1, else insert Known_P[<i>k</i>]=0.

<h3>- Known_Q</h3> A vector with length: #Number of busses. If the reactive power of the <i>k</i>'th bus is known, insert Known_Q[<i>k</i>]=1, else insert Known_Q[<i>k</i>]=0.

<h3>- V</h3> A vector with length: #Number of busses. If the voltage magnitude of the <i>k</i>'th bus is known and equal to <i>Vk</i>, insert V[<i>k</i>]=<i>Vk</i>, else insert V[<i>k</i>]=<i>initial guess</i>.

<h3>- A</h3> A vector with length: #Number of busses. If the voltage phase of the <i>k</i>'th bus is known, Known_A[<i>k</i>]=1, else: Known_A[<i>k</i>]=0.

<h3>- P</h3> A vector with length: #Number of busses. If the active power of the <i>k</i>'th bus is known, Known_P[<i>k</i>]=1, else: Known_P[<i>k</i>]=0.

<h3>- Q</h3> A vector with length: #Number of busses. If the reactive power of the <i>k</i>'th bus is known, Known_Q[<i>k</i>]=1, else: Known_Q[<i>k</i>]=0.
