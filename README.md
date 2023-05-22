# Exercices for the FAU Course "CPU Design mit VHDL"
## What you can find here
Here we save our source files for the different exercices and for the cpu we create.

## Properties of the CPU
We to create a CPU which can execute RV32I as a minimum ISA.
We plan to get RV32GC working on Machine Level. We will see... :)

## How to maintain the Vivado Projects
### How to create a new Project Folder
1) Create a folder under the root. Give it the desired project name.
2) Inside this folder create an "src" named folder and put your project local files in there.
3) Copy also the "make.tcl" Script from the "global_src" folder in the new project folder.
5) If you want to create a vivado project, goto: "How to create a local Vivado Project".

### How to (re)create a local Vivado Project
1) Execute the "make.tcl" script of the project you want to create a vivado project from. CAUTION: This will delete an existing vivado project in the vivado folder.
2) Vivado should now create a fresh project and opens it. The local and global source files will be added automatically.
3) The Vivado project (inside "vivado" folder) will not be tracked by git. But the source files will.
4) You can use this vivado project every time or delete the "vivado" folder and create a fresh one.
5) If you want to add source files to vivado, goto: "How to add sources to the Vivado Project".

### How to add sources to the Vivado Project
-  *.vhd will be added to sources.
-  *_top.vhd will be the top module of synthesis.
-  *_tb.vhd will be the top module of simulation.
-  *.wcfg will be added to waveforms in simulation.
-  *.xdc will be added to constraints.
1) Place the new file in the "src" or "global_src" folders.
2) Let vivado add it to your project or simply run the make.tcl script. DO NOT IMPORT (COPY) THE NEW FILE!
3) IMPORTANT: Do not let Vivado create source files in its own source folder. These files will not be tracked by git.
