function [history, seed] = runbattle(procedure, Nruns)

seed = [];
disp('  run   min     avg   max   avg time (miliseconds)')
for i = 1:Nruns
    seed(i) = battle('init', 0);
    tic; feval(procedure); times(i) = toc;
    [allshot, nshots] = battle('finish');
    if ~allshot
        error('Procedure exited without shooting all ships!')
    end

    history(i) = nshots;
    
    if mod(i, 100)==0 || i == Nruns
        fprintf('%5i  %4i    %3.1f  %4i    %5i\n', ...
            i, min(history), mean(history), max(history), round(mean(times)*1000));
%         hist(history);
%         drawnow;
    end    
end