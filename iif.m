function out = iif(cond,ctrue,cfalse)
%IIF implements a ternary operator (inline if)
% Importantly: the output is evalueted only if selected!

if isscalar(cond)
  if cond
    out = ctrue();
  else
    out = cfalse();
  end
else
  out = (cond).*ctrue() + (~cond).*cfalse();
end
