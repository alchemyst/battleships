% run 
savename = 'biasscore.mat';
d = dir('s*');
r = [];
h = waitbar(0, 'Running tests');
N = 1000;
errors = [];
for i = 1:length(d)
    filename{i} = d(i).name;
    fprintf('Testing %s ', filename{i});
    cd(filename{i})
    shots = zeros(1, N);
    seeds = shots;
    if exist('err', 'file')
        disp('error recorded')
    else
        if exist(savename, 'file')
            loadd = load(savename);
            shots = loadd.shots;
        else
            try
                disp('');
                [shots, seeds] = testfindships(N);
                disp('');
            catch
                disp('Error encountered')
            end
            save(savename, 'shots', 'seeds');
        end
    end
    r(i, :) = shots;
    errors(i) = min(shots)==0;
    if errors(i)
        system('touch err');
    else
        fprintf(' mean: %2.2f, errors: %i\n', mean(shots(shots~=0)), errors(i));
    end
    fprintf(' best so far: %2.2f\n', min(mean(r(find(errors==0), :)')));
    cd ..
    waitbar(i/length(d), h);
end
close(h)