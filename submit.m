function submit()

    % Copyright (C) 2013 Georgia Tech Research Corporation
    % see the LICENSE file included with this software

    clear java;
    clear classes;

    if (isdeployed)
        [path, folder, ~] = fileparts(ctfroot);
        root_path = fullfile(path, folder);
    else
        root_path = fileparts(mfilename('fullpath'));
    end
    addpath(genpath(root_path));

    s = simiam.ui.CourseraClient(root_path);
    s.load_ui();

end