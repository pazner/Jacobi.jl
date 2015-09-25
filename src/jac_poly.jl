r"""
Computes Jacobi polynomial $P_n^{a,b}(x)$.

This function computes the jacobi polynomial of degree `n` with weights
`a` and `b` at point x 
"""
function jacobi(x, n, a, b)
    ox = one(x)
    zx = zero(x)
    if n==0
        return ox
    elseif n==1
        return ox/2 * (a - b + (a + b + 2)*x)
    end
    
    p0 = ox
    p1 = ox/2 * (a - b + (a + b + 2)*x)
    p2 = zx;
    
    for i = 1:(n-1)
	a1 = 2*(i+1)*(i+a+b+1)*(2*i+a+b);
	a2 = (2*i+a+b+1)*(a*a-b*b);
	a3 = (2*i+a+b)*(2*i+a+b+1)*(2*i+a+b+2);
	a4 = 2*(i+a)*(i+b)*(2*i+a+b+2);
	p2 = ox/a1*( (a2 + a3*x)*p1 - a4*p0);

        p0 = p1
        p1 = p2
    end

    return p2
end
jacobi(x, n) = jacobi(x, n, zero(x), zero(x))
jacobi(x, n, a) = jacobi(x, n, a, zero(x))



"""
Computes Jacobi polynomial at an array of points.

This function computes the jacobi polynomial of degree `n` with weights
`a` and `b` at point x 
"""
function jacobi!{T<:Number}(x::AbstractArray{T}, n, a, b, y::AbstractArray{T})

    m = length(x)
    for i = 1:m
        y[i] = jacobi(x[i], n, a, b)
    end
    return y
end

jacobi{T<:Number}(x::AbstractArray{T}, n, a, b) = jacobi!(x, n, a, b, zeros(x))
jacobi{T<:Number}(x::AbstractArray{T}, n) = jacobi!(x, n, zero(T), zero(T), zeros(x))
jacobi{T<:Number}(x::AbstractArray{T}, n, a) = jacobi!(x, n, a, zero(T), zeros(x))




djacobi(x, n, a, b) =  one(x)/2 * (a + b + n + 1) * jacobi(x, n-1, a+1, b+1)

djacobi(x, n) = djacobi(x, n, zero(x), zero(x))
djacobi(x, n, a) = djacobi(x, n, a, zero(x))

function djacobi!{T<:Number}(x::AbstractArray{T}, n, a, b, y::AbstractArray{T})

    m = length(x)
    for i = 1:m
        y[i] = djacobi(x[i], n, a, b)
    end
    return y
end

djacobi{T<:Number}(x::AbstractArray{T}, n, a, b) = djacobi!(x, n, a, b, zeros(x))
djacobi{T<:Number}(x::AbstractArray{T}, n) = djacobi!(x, n, zero(T), zero(T), zeros(x))
djacobi{T<:Number}(x::AbstractArray{T}, n, a) = djacobi!(x, n, a, zero(T), zeros(x))


import Base.eps

eps{T<:AbstractFloat}(::Type{Complex{T}}) = eps(T)


function jacobi_zeros!{T<:Number}(m, alpha, beta, x::AbstractArray{T})

    o = one(T)
    z = zero(T)

    a = convert(T,alpha)
    b = convert(T,beta)

    const MAXITER = 500
    const EPS::T = 100 * eps(T)
    local i, k, iter=0

    for k = 1:m
        # Initial guess.
        r = -cos( (2k-o)/(2*m) * pi)
        if (k > 1)
            r = (r + x[k-1]) / 2
        end
        iter = 0
        while(true)
            s = z
            for i = 1:(k-1)
                s += o/(r - x[i])
            end
            
            poly = jacobi(r, m, a, b)
            delta = -poly / (djacobi(r, m, a, b) - poly*s)
            
            r += delta
            iter += 1
            
            if iter > MAXITER
                throw("Program did not converge")
            end
            
            if abs(delta) < abs(EPS)
                break
            end
        end
        x[k] = r
    end
        
    return x
        
end
    

  

function jacobi_zeros{T<:Number}(m, a, b, ::Type{T}=Float64)
    jacobi_zeros!(m, a, b, zeros(T,m))
end

jacobi_zeros(m) = jacobi_zeros(m, 0.0, 0.0)
jacobi_zeros(m, a) = jacobi_zeros(m, a, zero(a))
