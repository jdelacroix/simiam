function launch()

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software

clear java;
clear classes;

addpath(genpath('bundled'));

app = simiam.ui.AppWindow();
app.load_ui();

end