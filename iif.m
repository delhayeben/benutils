function out = iif(cond,ctrue,cfalse)
%IIF implements a ternary operator (inline if)
% Importantly: the output is evalueted only if selected!

if isscalar(cond)
  if cond
    out = ctrue; % previously ctrue();
  else
    out = cfalse; % previously cfalse(); to avoid to evaluate if not needed
  end
else
  out = (cond).*ctrue + (~cond).*cfalse; % same for ctrue and cfalse
end
