function launch()

% Copyright (C) 2013 Georgia Tech Research Corporation
% see the LICENSE file included with this software

clear java;
clear classes;

if (isdeployed)
    [path, folder, extension] = fileparts(ctfroot);
    root_path = fullfile(path, folder);
else
    root_path = fileparts(mfilename('fullpath'));
end
addpath(genpath(root_path));
root_path = 'H:\\Documents\GitHub\simiam';
app = simiam.ui.AppWindow(root_path);
app.load_ui();

end
