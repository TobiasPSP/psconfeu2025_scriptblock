# Real World

To appreciate the use of all of the previous:

- **Modularization:** keep extensive technical script blabla **separated** from the **important production workflows**. No 1000-line scripts for *operations*, no *"change path in line 278"* please
- **Ease of Use for Non-PowerShell-Gurus:** Scriptblocks can **enhance user experience** through **parameters** and **Intellisense for Arguments**
- **Speed:** Since *Scriptblocks* (and thus *functions* and *cmdlets*) can be made *pipeline-aware*, this allows for **simple multi-theading** and extensive speed gains (*in suitable use cases*)
- **Dependencies:** *Modules* introduce **dependencies**, however they can easily be incorporated into single scripts, either manually or automatically through tools.
