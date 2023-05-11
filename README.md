# Exercices for the FAU Course "CPU Design mit VHDL"
## What you can find here
Here we save our source files for the different exercices and for the cpu we create.

## Properties of the CPU
We to create a CPU which can execute RV32I as a minimum ISA.
We plan to get RV32GC working on Machine Level. We will see...

## How to create a Vivado Project
1) Create a folder in the root. Give it the project name.
2) Inside this folder create an "src" named folder and put your project local files in there.
3) Copy also the "make_backup.tcl" Script from the "global_src" folder in the new project folder.
4) You can now rename this file to "make.tcl" and execute it with vivado.
5) Vivado should now create a fresh project and opens it. The local and global source files will be added automatically.
6) The Vivado project (inside "vivado" folder) will not be tracked by git. But the source files will.

## How to add sources to the Vivado Project
- If you want to add a source file place it in the "src" or "global_src" folders.
  Then add it to your project. DO NOT IMPORT IT!
- Do not let Vivado create source files in its own source folder. These files will not be tracked by git.
