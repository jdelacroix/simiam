// Copyright (C) 2014, Georgia Tech Research Corporation
// see the LICENSE file included with this software

#ifdef _WIN64 || _WIN32 || __APPLE__
    #include <SDL.h>
#else
    // Linux
    #include <SDL2/SDL.h>
#endif

#include <iostream>
#include <vector>
#include "mex.h"

extern void _main();

class Joystick {

private:
	SDL_Joystick* aJoystick;
    
public:
	Joystick();
	~Joystick();
	
	void getControllerStates(std::vector<double>& jsAxes, std::vector<double>& jsButtons); 
};

Joystick::Joystick()
{
	// 1. Initialize the SDL subsystems.
    if (SDL_InitSubSystem(SDL_INIT_JOYSTICK)) {
        mexErrMsgTxt("Unable to initialize SDL and its subsystems.");
    }
    
    SDL_JoystickEventState(SDL_ENABLE);
    
    int nJoysticks = SDL_NumJoysticks();
    
    // 2. Use the first available compatible game controller.
    if (nJoysticks > 0) {
        for (int i=0; i<nJoysticks; i++) {
            std::cout << SDL_JoystickNameForIndex(i) << " is a compatible joystick." << std::endl;
            aJoystick = SDL_JoystickOpen(i);
            if (aJoystick) {
                break;
            } else {
                mexErrMsgTxt("Unable to open joystick.");
            }           
        }
    } else {
        mexErrMsgTxt("No joysticks were found.");
    }
}

Joystick::~Joystick()
{
//     SDL_JoystickClose(aJoystick);
// 	SDL_Quit();
}

void Joystick::getControllerStates(std::vector<double>& jsAxes, std::vector<double>& jsButtons) {
    
    if (aJoystick) {
        SDL_JoystickUpdate();
    
        int nAxes = SDL_JoystickNumAxes(aJoystick);
        for (int i=0; i<nAxes; i++) {
            jsAxes.push_back(SDL_JoystickGetAxis(aJoystick, i));
        }

        int nButtons = SDL_JoystickNumButtons(aJoystick);
        for (int i=0; i<nButtons; i++) {
            jsButtons.push_back(SDL_JoystickGetButton(aJoystick, i));
        }
    }
}

static void mexcpp(mxArray *plhs[])
{
	Joystick *aJoystick = new Joystick(); 
      
    std::vector<double> jsAxes;
	std::vector<double> jsButtons;
    
    jsAxes.clear();
    jsButtons.clear();
    
	aJoystick->getControllerStates(jsAxes, jsButtons);
    
    plhs[0] = mxCreateDoubleMatrix(jsAxes.size(), 1, mxREAL);
	plhs[1] = mxCreateDoubleMatrix(jsButtons.size(), 1, mxREAL);
    
    double* axes;
	double*	buttons;

    axes = mxGetPr(plhs[0]);
	buttons = mxGetPr(plhs[1]);

	for (int i=0; i<jsAxes.size(); i++) {
		*(axes+i) = jsAxes.at(i);	
	}

	for (int i=0; i<jsButtons.size(); i++) {
		*(buttons+i) = jsButtons.at(i);	
	}
    
	delete(aJoystick);
	
	return;
}

void mexFunction(
		 int            nlhs,
		 mxArray        *plhs[],
		 int            nrhs,
		 const mxArray  *prhs[]
		 )
{
    if (nrhs != 0) {
        mexErrMsgTxt("No input arguments are needed for GameController.");
    }
	
	mexcpp(plhs);
	return;
}