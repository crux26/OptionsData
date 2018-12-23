% des(gather())

n = 10;
spmd
  C = codistributed(magic(n));
  M = gather(C) % Gather all elements to all workers
end
S = gather(C)   % Gather elements to client

% Gather all of the elements of C onto worker 1, for operations that cannot be performed across distributed arrays.

n = 10;
spmd
  C = codistributed(magic(n));
  out = gather(C,1);
  if labindex == 1
    % Characteristic sum for this magic square:
    characteristicSum = sum(1:n^2)/n;
    % Ensure that the diagonal sums are equal to the 
    % characteristic sum:
    areDiagonalsEqual = isequal ...
      (trace(out),trace(flipud(out)),characteristicSum)
  end
end


n = 10;
D = distributed(magic(n)); % Distribute array to workers
M = gather(D)              % Return array to client
% Gather the results of a GPU operation to the MATLAB workspace.

G = gpuArray(rand(1024,1));
F = sqrt(G);   % Input and output are both gpuArray
W = gather(G); % Return array to workspace
whos
