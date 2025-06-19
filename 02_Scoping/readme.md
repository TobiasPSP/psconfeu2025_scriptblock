# Scoping

*ScriptBlocks* **can** create an isolated variable scope. Depending on how you *invoke* scriptblocks, you may explicitly *waive* the scoping feature.

By default, when you run a script or function, it runs with scope. 

Invoke a script or function with `.` to disable the scope (useful for debugging as all internal variables are still accessible once a script or function ends).
