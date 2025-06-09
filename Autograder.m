clear
folder = './assignment_6157338_export'; % directory which stores students' codes
SID_Name_Mapping = readtable('SID_Name_Mapping.csv'); % need to generate it following the format (SID/Name) See the SID_Name_Mapping.csv file
cd(folder)

submissionList = dir("./submission*");
nFile   = length(submissionList);
success = false(1, nFile);
file1 = cell(nFile,1);
csv = zeros(nFile,1);

%Set up test cases
params.root_tol = 1e-7; params.func_tol = 1e-7; params.maxit = 100;

%% EASY / full score if num_fcall <= 25
func1 = @(x) x*exp(-x) - 2*x + 1;           Int1.a = 0;     Int1.b = 3;
func2 = @(x) x*cos(x) - 2*x^2 + 3*x - 1;    Int2.a = 1;     Int2.b = 3;
func3 = @(x) x^3-7*x^2+14*x-6;              Int3.a = 0;     Int3.b = 1;
func4 = @(x) sqrt(x)-cos(x);                Int4.a = 0;     Int4.b = 1;
func5 = @(x) 2*x*cos(2*x) - (x+1)^2;        Int5.a = -4;    Int5.b = -2;
%% HARD / full score + extra if num_fcall <= 25 
func6 = @(x) x^3 - 32*x + 128;              Int6.a = -8;    Int6.b = 0;
func7 = @(x) x^4 -2*x^3-4*x^2+4*x+4;        Int7.a = 0;     Int7.b = 2;
func8 = @(x) -x^3 - cos(x);                 Int8.a = -3;    Int8.b = 3;
func9 = @(x) (x-5)^7 - 1e-1;                Int9.a = 0;   Int9.b = 10; 
func10 = @(x) (x-3)^11;                     Int10.a = 2.4;   Int10.b = 3.4; 

test_functions = {func1, func2, func3, func4, func5, func6, func7, func8, func9, func10};
test_intervals = {Int1, Int2, Int3, Int4, Int5, Int6, Int7, Int8, Int9, Int10};

%% Get Results
failure_list = {};
profile on
istart = 1;

for i = istart:nFile
    %%%%%%%%%%%%%%%%%%%%%%%%
    % Add the initialization
    clear roots fcalls roots_scores fcalls_scores score_extra
    % Raehyun
    %%%%%%%%%%%%%%%%%%%%%%%%
    
    failed = 0;
    submissionName = submissionList(i).name;
    pattern = fullfile(submissionName, 'modified*.m');
    fileList = dir(pattern);
    filename = fileList.name;  
    [~, funcName] = fileparts(filename);
    filename = funcName;
    SID = str2double(filename(15:end));
    
    disp(filename);
    addpath(submissionName)
    for j = 1:10
        % Int.a = test_intervals{j}(1); Int.b = test_intervals{j}(2);
        func = test_functions{j};
        Int = test_intervals{j};
        myfunctionstring = [filename, '(test_functions{j}, Int, params);'];
        try
            profile on
            [root, info] = eval(myfunctionstring);
            profile off
            
            %%%%%%%%%%%%%%%%%%%%%%%%
            % When root is not numeric, put an invalid value.
            if (isnumeric(root) == 0 || isempty(root))
                root = Int.b+10;
            end
            % Raehyun
            %%%%%%%%%%%%%%%%%%%%%%%%
            
            %Store Roots
            roots(1, j) = root;
            %Grade Roots
            if or(isnan(root), isinf(root))
                fcalls(1, j) = inf;
                roots_scores(1, j) = 0;
                fcalls_scores(1, j) = 0;
            else
                root_tol_check = abs(root - fzero(test_functions{j}, root)) < params.root_tol;
                func_tol_check = abs(test_functions{j}(root)) < params.func_tol;
                int_check = (root > Int.a) & (root < Int.b);
                %%%%%%%%%%%%%%%%%%%%%%%%
                % Modified to return 0 value when it can't find a proper root
                % root_tol_check OR func_tol_check
%                 if root_tol_check & func_tol_check & int_check
                if (root_tol_check || func_tol_check) && int_check
                    flag_root = true;
                    roots_scores(1, j) = 70;
                else
                    flag_root = false;
                    roots_scores(1, j) = 0;
                end
                % Raehyun
                %%%%%%%%%%%%%%%%%%%%%%%%
                %Store Number of Function Calls
                p = profile('info');
                foo = {p.FunctionTable.CompleteName};
                bar = strfind(foo, func2str(func));
                bar2 = strfind(foo, vectorize(func2str(func)));
                fcall_idx = find(~cellfun(@isempty, bar));
                fcall_idx2 = find(~cellfun(@isempty, bar2));
                num_fcall = 0;
                if ~isempty(fcall_idx)
                    sz = size(fcall_idx);
                    num_fcall = num_fcall + p.FunctionTable(fcall_idx(1)).NumCalls;
                    if sz(2) == 2
                        num_fcall = num_fcall + p.FunctionTable(fcall_idx(2)).NumCalls;
                    end
                end
                thd1 = 25;
                fcalls(1, j) = num_fcall;
                if fcalls(1, j) <= thd1 && flag_root
                    fcalls_scores(1,j) = 30;        
                else
                    fcalls_scores(1,j) = 0;
                end

                if fcalls_scores(1,j) == 30 && j >= 6 && flag_root
                    score_extra(1,j) = true;
                else
                    score_extra(1,j) = false;
                end
            end
        catch
            fprintf('failed: %s\n', filename);
            failed = 1;
        end
    end
    [~, name_idx] = ismember(SID, SID_Name_Mapping{:, 1});
    if name_idx ~= 0
        Results_table{i, 1} = SID;
        Results_table{i, 2} = SID_Name_Mapping{name_idx, 2}{:};
    end
    if failed == 0
        Results_table{i, 3} = roots;
        Results_table{i, 4} = fcalls;
        Results_table{i, 5} = roots_scores;
        Results_table{i, 6} = fcalls_scores;
        Results_table{i, 7} = score_extra;
        Results_table{i, 8} = sum(roots_scores);
        Results_table{i, 9} = sum(fcalls_scores);
        Results_table{i, 10} = sum(score_extra);
        Results_table{i, 11} = (Results_table{i, 8} + Results_table{i, 9})/50 + Results_table{i,10};
    else
        failure_list{end+1} = filename;
    end
    rmpath(submissionName)
end
writecell(Results_table,'../PAres_final.xls')
writecell(failure_list,'../PAres_failed.xls')

