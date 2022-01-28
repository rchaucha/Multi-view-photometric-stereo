function v = shrink(x,a)

v = sign(x).*max(abs(x)-a,0);