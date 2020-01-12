% TESTFINDSHIPS test implementation
%    TESTFINDSHIPS(N) will run FINDSHIPS N times and display statistics
%    about the runs.  It will return the results of all the games.

% Author: Carl Sandrock

function [history, seed] = testfindships(Nruns)

seed = [];
disp('  run   min     avg   max   avg time (miliseconds)')
for i = 1:Nruns
    seed(i) = battle('init', 0);
    tic; evalc('findships'); times(i) = toc;
    [allshot, nshots] = battle('finish');
    if ~allshot
        error('Procedure exited without shooting all ships!')
    end

    history(i) = nshots;
    
    if mod(i, 100)==0 || i == Nruns
        fprintf('%5i  %4i    %3.1f  %4i    %5i\n', ...
            i, min(history), mean(history), max(history), round(mean(times)*1000));
    end    
end