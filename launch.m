function launch()

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software

clear java;
clear classes;

root_path = fileparts(which(mfilename));
addpath(genpath(root_path));

app = simiam.ui.AppWindow(root_path);
app.load_ui();

end