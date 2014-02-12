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

class GameController {

private:
	SDL_GameController* aGameController;
    
public:
	GameController();
	~GameController();
	
	void getControllerStates(std::vector<double>& gcAxes, std::vector<double>& gcButtons); 
};

GameController::GameController()
{
	// 1. Initialize the SDL subsystems.
    if (SDL_InitSubSystem(SDL_INIT_JOYSTICK | SDL_INIT_GAMECONTROLLER)) {
        mexErrMsgTxt("Unable to initialize SDL and its subsystems.");
    }
    
    SDL_GameControllerEventState(SDL_ENABLE);
    
    int nJoysticks = SDL_NumJoysticks();
    
    // 2. Use the first available compatible game controller.
    if (nJoysticks > 0) {
        for (int i=0; i<nJoysticks; i++) {
            if (SDL_IsGameController(i)) {
                std::cout << SDL_GameControllerNameForIndex(i) << " is a compatible game controller." << std::endl;
                aGameController = SDL_GameControllerOpen(i);
                if (aGameController) {
                    break;
                } else {
                    mexErrMsgTxt("Unable to open game controller");
                }
            } else {
                std::cout << "Device " << i << " is not a compatible game controller." << std::endl;
                aGameController = NULL;
            }           
        }
    } else {
        mexErrMsgTxt("No game controllers were found.");
    }
}

GameController::~GameController()
{
    SDL_GameControllerClose(aGameController);
	SDL_Quit();
}

void GameController::getControllerStates(std::vector<double>& gcAxes, std::vector<double>& gcButtons) {
    
    if (aGameController) {
        SDL_Joystick *aJoystick = SDL_GameControllerGetJoystick(aGameController);
        SDL_JoystickUpdate();
    
        int nAxes = SDL_JoystickNumAxes(aJoystick);
        for (int i=0; i<nAxes; i++) {
            gcAxes.push_back(SDL_JoystickGetAxis(aJoystick, i));
        }

        int nButtons = SDL_JoystickNumButtons(aJoystick);
        for (int i=0; i<nButtons; i++) {
            gcButtons.push_back(SDL_JoystickGetButton(aJoystick, i));
        }
    }
}

static void mexcpp(mxArray *plhs[])
{
	GameController *aGameController = new GameController(); 
      
    std::vector<double> gcAxes;
	std::vector<double> gcButtons;
    
    gcAxes.clear();
    gcButtons.clear();
    
	aGameController->getControllerStates(gcAxes, gcButtons);
    
    plhs[0] = mxCreateDoubleMatrix(gcAxes.size(), 1, mxREAL);
	plhs[1] = mxCreateDoubleMatrix(gcButtons.size(), 1, mxREAL);
    
    double* axes;
	double*	buttons;

    axes = mxGetPr(plhs[0]);
	buttons = mxGetPr(plhs[1]);

	for (int i=0; i<gcAxes.size(); i++) {
		*(axes+i) = gcAxes.at(i);	
	}

	for (int i=0; i<gcButtons.size(); i++) {
		*(buttons+i) = gcButtons.at(i);	
	}
    
	delete(aGameController);
	
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