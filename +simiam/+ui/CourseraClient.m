classdef CourseraClient < handle
    
% Copyright (C) 2013, Georgia Tech Research Corporation
% see the LICENSE file included with this software
    
    properties
        root_url
        
        part_layout
        layout
        parent
        
        ui_colors
        ui_size
        
        login_field
        password_field
        submit_button
        
        part_list
        course_url
        course_week
    end
    
    methods
        
        function obj = CourseraClient(root_url) 
            obj.root_url = root_url;
            obj.ui_colors = struct('gray',  [220 220 220]/255, ...
                                   'green', [ 57 200  67]/255, ...
                                   'red',   [221  23  31]/255, ...
                                   'dgray', [183 183 183]/255, ...
                                   'lgray', [242 242 242]/255, ...
                                   'black', [ 48  48  48]/255, ...
                                   'white', [255 255 255]/255);
            obj.part_list = simiam.containers.ArrayList(10);
        end
        
        function load_ui(obj)
            obj.populate_assignment();
            obj.create_ui();
        end
        
        function populate_assignment(obj)
            
            % Read in XML file
            blueprint = xmlread(fullfile(obj.root_url, 'coursera.xml'));
            
            % Parse XML file for robot configurations
            e = blueprint.getElementsByTagName('course').item(0);
            obj.course_url = ['http://class.coursera.org/' char(e.getAttribute('identifier'))];
            week_t = str2double(e.getAttribute('week'));
            
            assignment = blueprint.getElementsByTagName('assignment').item(week_t-1);
            obj.course_week = str2double(assignment.getAttribute('week'));
            
            part_list_t = assignment.getElementsByTagName('part');
            for k = 0:(part_list_t.getLength-1)
                part_i = part_list_t.item(k);
                
                identifier = char(part_i.getAttribute('identifier'));
                title = char(part_i.getAttribute('title'));
                test = str2func(['simiam.test.' char(part_i.getAttribute('test')) '.run_test']);
                
                part_i = struct('identifier', identifier, ...
                                'title', title, ...
                                'test', test, ...
                                'checkbox', 0);
                          
                obj.part_list.appendElement(part_i);
            end
        end
        
        function create_ui(obj)
            obj.parent = figure('MenuBar', 'none', ...
                                'NumberTitle', 'off', ...
                                'Name', 'Sim.I.am: Programming Assignment Submission', ...
                                'Color', obj.ui_colors.gray);
                            
            n_parts = obj.part_list.length();                
            obj.ui_size = [0 0 3*128 256+n_parts*(48+10)];
                            
            ui_new_size = get(obj.parent, 'Position');
            ui_new_size(3:4) = obj.ui_size(3:4);
            screen_size = get(0, 'ScreenSize');
            margins = (screen_size(3:4)-obj.ui_size(3:4))/2;
            ui_new_size(1:2) = margins;
            set(obj.parent, 'Position', ui_new_size);

                            
            obj.layout = GridLayout(obj.parent, 'RowHeight', {96,32,32,'*',32}, ....
                                                'ColWidth', {128, '*'}, ...,
                                                'LMargin', 10, 'RMargin', 6, ...
                                                'Gap', 5, ...
                                                'CellColor', obj.ui_colors.gray);
                                            
            set(obj.layout.Container, 'BackgroundColor', obj.ui_colors.gray);            
            MergeCells(obj.layout, 4, [1 2]);            
            MergeCells(obj.layout, 5, [1 2]);
            Update(obj.layout);
            
            
            button_string = '<html>Login:</html>';
            ui_args = {'Style','pushbutton', 'String', button_string, 'ForegroundColor', 'k', 'FontWeight', 'bold', 'BackgroundColor', obj.ui_colors.gray, 'Callback', ''};
            ui_parent = obj.layout.Cell(2,1);
            aButtonLabel = uicontrol(ui_parent, ui_args{:});
            set(findjobj(aButtonLabel), 'BorderPainted', 0);
            set(aButtonLabel, 'Enable', 'inactive');
            
            ui_args = {'Style','edit', 'String', '', 'ForegroundColor', 'k', 'FontWeight', 'normal', 'BackgroundColor', obj.ui_colors.white, 'Callback', ''};
            ui_parent = obj.layout.Cell(2,2);
            obj.login_field = uicontrol(ui_parent, ui_args{:});
            
            button_string = '<html>Password:</html>';
            ui_args = {'Style','pushbutton', 'String', button_string, 'ForegroundColor', 'k', 'FontWeight', 'bold', 'BackgroundColor', obj.ui_colors.gray, 'Callback', ''};
            ui_parent = obj.layout.Cell(3,1);
            aButtonLabel = uicontrol(ui_parent, ui_args{:});
            set(aButtonLabel, 'Enable', 'inactive');
            set(findjobj(aButtonLabel), 'BorderPainted', 0);
            
            ui_args = {'Style','edit', 'String', '', 'ForegroundColor', 'k', 'FontWeight', 'normal', 'BackgroundColor', obj.ui_colors.white, 'Callback', ''};
            ui_parent = obj.layout.Cell(3,2);
            obj.password_field = uicontrol(ui_parent, ui_args{:});
            
            icon_file = fullfile(obj.root_url, 'resources/simiam-round-small.png');
            if(isunix)
                icon_url = ['file://' icon_file];
            else
                icon_url = strrep(['file:/' icon_file],'\','/');
            end
            button_string = ['<html><div style="text-align: center"><img src="' icon_url '"/></div></html>'];
            ui_args = {'Style','pushbutton', 'String', button_string, 'ForegroundColor', 'k', 'FontWeight', 'bold', 'BackgroundColor', obj.ui_colors.gray, 'Callback', ''};
            ui_parent = obj.layout.Cell(1,1);
            aButtonLabel = uicontrol(ui_parent, ui_args{:});
            set(findjobj(aButtonLabel), 'BorderPainted', 0);
            set(aButtonLabel, 'Enable', 'inactive');
            
            button_string = '<html>Remember to use your submission login and password!</html>';
            ui_args = {'Style','pushbutton', 'String', button_string, 'ForegroundColor', 'k', 'FontWeight', 'bold', 'BackgroundColor', obj.ui_colors.gray, 'Callback', ''};
            ui_parent = obj.layout.Cell(1,2);
            aButtonLabel = uicontrol(ui_parent, ui_args{:});
            set(findjobj(aButtonLabel), 'BorderPainted', 0);
            set(aButtonLabel, 'Enable', 'inactive');
            
            
            
            n_parts = obj.part_list.length();
            part_panel = uipanel( ...
                                'Parent', obj.layout.Cell(4,1), ...
                                'Title', sprintf('Assignment parts:'), ...
                                'Units', 'pixels', ...
                                'BackgroundColor', obj.ui_colors.gray);
            obj.part_layout = GridLayout(part_panel, 'NumRows', n_parts, 'RowHeight', 48,...
                                                     'ColWidth', {32, '*', 32}, ...,
                                                     'Gap', 5, ...
                                                     'CellColor', obj.ui_colors.gray);
                                                       
            for i = 1:n_parts
                part = obj.part_list.elementAt(i);
                
                ui_parent = obj.part_layout.Cell(i,1);
                ui_args = {'Style','checkbox', 'String', '', 'BackgroundColor', obj.ui_colors.gray, 'Callback', ''};
                part_i = uicontrol(ui_parent, ui_args{:});
                set(part_i, 'Value', 1);
                part.checkbox = part_i;
               
                
%                 button_string = ['<html><p align="left">' list_items{i} '</p></html>'];
                button_string = part.title;
                ui_args = {'Style','edit', 'String', button_string, 'ForegroundColor', 'k', 'FontWeight', 'bold', 'BackgroundColor', obj.ui_colors.gray, 'HorizontalAlignment', 'left'};
                ui_parent = obj.part_layout.Cell(i,2);
                aButtonLabel = uicontrol(ui_parent, ui_args{:});
%                 set(findjobj(aButtonLabel), 'BorderPainted', 0);
                set(aButtonLabel, 'Enable', 'inactive');
                set(aButtonLabel, 'Max', 10);
%                 set(aButtonLabel, 'HorizontalAlignment', 'left');
                part.label = aButtonLabel;
                
                ui_args = {'Style','pushbutton', 'String', button_string, 'ForegroundColor', 'k', 'FontWeight', 'bold', 'BackgroundColor', obj.ui_colors.gray, 'HorizontalAlignment', 'left'};
                ui_parent = obj.part_layout.Cell(i,3);
                aButtonLabel = uicontrol(ui_parent, ui_args{:});
                set(findjobj(aButtonLabel), 'BorderPainted', 0);
                set(aButtonLabel, 'Enable', 'inactive');
                obj.ui_set_button_icon(aButtonLabel, 'ui_status_unknown.png');
                part.status = aButtonLabel;
                
                obj.part_list.replaceElementAt(part, i);
            end
            
            
            button_string = '<html>Submit to Coursera for Grading</html>';
            ui_args = {'Style','pushbutton', 'String', button_string, 'ForegroundColor', 'k', 'FontWeight', 'bold', 'BackgroundColor', obj.ui_colors.dgray, 'Callback', @obj.ui_pressed_submit};
            ui_parent = obj.layout.Cell(5,1);
            obj.submit_button = uicontrol(ui_parent, ui_args{:});
            
            Update(obj.layout);
            Update(obj.part_layout);
            
            set(obj.parent, 'CloseRequestFcn', @obj.ui_close);
            
            if exist('coursera_login_data.mat','file')
                load('coursera_login_data.mat');
                set(obj.login_field, 'String', login)
                set(obj.password_field, 'String', password);
            end
        end
        
        function ui_set_button_icon(obj, ui_button, icon)
            icon_file = fullfile(obj.root_url, 'resources/icons', icon);
            if(isunix)
                icon_url = ['file://' icon_file];
            else
                icon_url = strrep(['file:/' icon_file],'\','/');
            end
            button_string = ['<html><img src="' icon_url '"/></html>'];
            set(ui_button, 'String', button_string);
        end
        
        function ui_pressed_submit(obj, src, event)
            
            % save login and password information
            login = get(obj.login_field, 'String');
            password = get(obj.password_field, 'String');
            save('coursera_login_data.mat', 'login', 'password');
            
            for i = 1:length(obj.part_list)
                part_i = obj.part_list.elementAt(i);
                obj.ui_set_button_icon(part_i.status, 'ui_status_unknown.png');
                set(part_i.label, 'String', part_i.title);
            end
            drawnow;
            
            for i = 1:length(obj.part_list)
                part_i = obj.part_list.elementAt(i);
                if get(part_i.checkbox, 'Value')
                    
                    [login, ch, signature, auxstring] = obj.get_challenge_from_coursera(login, part_i.identifier);
                    if isempty(login) || isempty(ch) || isempty(signature)
                        % Some error occured, error string in first return element.
                        fprintf('\n!! Error: %s\n\n', login);
                        return
                    end
                    
                    % Attempt Submission with Challenge
                    ch_resp = obj.generate_challenge_response(login, password, ch);

                    [result, str] = obj.submit_solution_to_coursera(login, ch_resp, part_i.identifier, ...
                           obj.evaluate_test_fcn(part_i.test, auxstring), obj.read_fcn_source(part_i.test), signature);
                       
                    if (result == 0)
                        obj.ui_set_button_icon(part_i.status, 'ui_status_ok.png');
                    else
                        obj.ui_set_button_icon(part_i.status, 'ui_status_error.png');
%                         fprintf('Feedback: %s\n', str);
                        label = get(part_i.label, 'String');
                        set(part_i.label, 'String', sprintf('%s',[label ': <Feedback> ' str]));
                    end
                end
            end
            
        end
        
        function ui_close(obj, src, event)
            delete(src);
        end
        
        %% Coursera-specific functionality (derived from assignment-api-examples.zip)
%         
        function [email,ch,signature,auxstring] = get_challenge_from_coursera(obj, login, part_id)
            challenge_url = [obj.course_url '/assignment/challenge'];
            str = urlread(challenge_url(), 'post', {'email_address', login, 'assignment_part_sid', part_id, 'response_encoding', 'delim'});
            
            str = strtrim(str);
            r = struct;
            while(numel(str) > 0)
                [f, str] = strtok (str, '|');
                [v, str] = strtok (str, '|');
                r = setfield(r, f, v);
            end
            
            email = getfield(r, 'email_address');
            ch = getfield(r, 'challenge_key');
            signature = getfield(r, 'state');
            auxstring = getfield(r, 'challenge_aux_data');
        end
        
        function [str] = generate_challenge_response(obj,email, passwd, challenge)
            str = simiam.util.SecureHashAlgorithm.generate_sha1_hash([challenge passwd]);
        end
        
        function out = evaluate_test_fcn(obj, fcn, aux_string) 
          out = sprintf('%s', fcn(aux_string, obj.root_url));
        end

        function src = read_fcn_source(obj, filename)
            src = '';
        end
        
        function [result, str] = submit_solution_to_coursera(obj, email, ch_resp, sid, output, ...
                source, signature)
            
            params = {'assignment_part_sid', sid, ...
                'email_address', email, ...
                'submission', simiam.util.EncodingScheme.encode_in_base64(output, ''), ...
                'submission_aux', simiam.util.EncodingScheme.encode_in_base64(source, ''), ...
                'challenge_response', ch_resp, ...
                'state', signature};
            
            submit_url = [obj.course_url '/assignment/submit'];
            [str, status] = urlread(submit_url, 'post', params);
            
            % Parse str to read for success / failure
            result = -1;
            
            if strcmp(str, 'Fantastic!')
                result = 0; 
            else
                
            end
            
            
        end

        
    end
    
end
