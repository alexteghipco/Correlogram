function [oMat] = combMats(mat1,mat2,diag)
% Combine upper triangle from mat1 and lower triangle from mat2 into one
% square matrix oMat. mat1 and mat2 must be of same size. Leave diag empty
% to keep diagonal from lower triangle. Otherwise, diag can be an n x 1
% vector with same length n as mat1/mat2 to pass in your own diagonal. Or
% it can be set to a single value to make entire diagonal that value.
%
% [oMat] = combMats(mat1,mat2,diag)
% Example call: oMat = combMats(mat1,mat2,[]);
% alex.teghipco@sc.edu

if size(mat1,1) ~= size(mat2,1) || size(mat1,2) ~= size(mat2,2)
    error('Matrices must be the same size')
end

ut = triu(mat1);
lt = tril(mat2);
oMat = ut + tril(lt,-1);

if ~isempty(diag)
    if length(diag) ~= 1 && length(diag) ~= size(mat1,1)
        error('Your passed in diag is not the correct length (see number of rows in mat1)')
    end
    oMat(find(eye(size(oMat)))) = diag;    
end
