# Graphic Plus
### Introduce
* This is a Visual Studio 2013 Project because CUDA 32bit version only support vs2013 and earlier.  
* This project is a graphic dll of GameMaker8.0 using CUDA 10.1.  
* There is a unfortunate news that if you use this dll on you GM8 game, every player must install CUDA on their computer to run dll.  
* It just a shit.
____
### Updata log：

#### 2019/9/17 Ver0.3
* Add invert function

#### 2019/9/16 Ver0.2
* Use class 'Effect' to manager cuda function.
* Add box blur function.
* Add box blur mossaic function.
* Add mosaic function -- square and circle.

#### 2019/9/14 Ver0.1
* Create Project.  
* Add gray scale function.  
____
### How to read code
* 'Gmapi\*.h' and 'Gmapi*\.cpp' files are from GMAPI.
* 'Graphic Plus.h' and 'Graphic Plus.cpp' is the core file in which defined the class 'Effect'.
* '\*.cu\*' is CUDA files, include kernel algorithms.
* The class Effect use its constructor function register CUDA functions, then in its 'exec()' function call GMAPI functions, D3D8 functions and registered CUDA functions.
