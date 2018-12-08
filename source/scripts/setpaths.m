% add everything to the matlab path so we can call all the functions we
% need
% for now this only adds from source folder and all subfolders, ie
% benchmarks is not included.
% might move benchmarks or expand this up later.

SOURCE_ROOT = fullfile('../');

folders = get_all_subfolders(SOURCE_ROOT);
cellfun( @(str) addpath(fullfile(SOURCE_ROOT, str)), folders, 'un',false);

function out = get_subfolders(folder_str)

    d = dir(folder_str);
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';
    nameFolds(startsWith(nameFolds, '.')) = [];
    
    out = nameFolds;
end

function out = get_all_subfolders(folder_str)
    children = get_subfolders(folder_str);
    
    L = size(children);
    for i = 1:L
        GC = get_all_subfolders(fullfile(folder_str,children{i}));
        disp ('*')
        disp(fullfile(folder_str,children{i}))
        disp('*')
        if ~isempty(GC)
            GC = cellfun(@(x) fullfile(children{i}, x), GC, 'un', false);
            children = [children; GC];
        end
    end
    
    out = children;
end