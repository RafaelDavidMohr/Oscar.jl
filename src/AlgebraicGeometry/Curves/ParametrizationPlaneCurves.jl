# export map_to_rational_normal_curve
# export rat_normal_curve_anticanonical_map
# export rat_normal_curve_It_Proj_Odd
# export rat_normal_curve_It_Proj_Even
# export invert_birational_map


################################################################################
function _tosingular(C::ProjectivePlaneCurve{QQField})
    F = defining_equation(C)
    T = parent(F)
    Tx = singular_poly_ring(T)
    return Tx(F)
end

function _fromsingular_ring(R::Singular.PolyRing)
    Kx = base_ring(R)
    if Kx isa Singular.N_AlgExtField
        FF, t = rational_function_field(QQ, "t")
        f = numerator(FF(Kx.minpoly))
        K, _ = number_field(f, "a")
    else
        K = QQ
    end
    newring, _ = polynomial_ring(K, symbols(R))
    return newring
end

function _tosingular_ideal(C::ProjectiveCurve)
    I = vanishing_ideal(C)  # computes a radical. Do we want this?
    singular_assure(I)
    return I.gens.S
end

@doc raw"""
    parametrization(C::ProjectivePlaneCurve{QQField})

Return a rational parametrization of  `C`. 

# Examples
```jldoctest
julia> R, (x,y,z) = graded_polynomial_ring(QQ, ["x", "y", "z"]);

julia> C = ProjectivePlaneCurve(y^4-2*x^3*z+3*x^2*z^2-2*y^2*z^2)
Projective plane curve
  defined by 0 = 2*x^3*z - 3*x^2*z^2 - y^4 + 2*y^2*z^2

julia> parametrization(C)
3-element Vector{QQMPolyRingElem}:
 12*s^4 - 8*s^2*t^2 + t^4
 -12*s^3*t + 2*s*t^3
 8*s^4

```
"""
function parametrization(C::ProjectivePlaneCurve{QQField})
    s = "local"
    F = _tosingular(C)
    L = Singular.LibParaplanecurves.paraPlaneCurve(F, s)
    R = L[1]
    J = [L[2][i] for i in keys(L[2])][1]
    S = _fromsingular_ring(R)
    return gens(ideal(S, J))
end

@doc raw"""
    adjoint_ideal(C::ProjectivePlaneCurve{QQField})

Return the Gorenstein adjoint ideal of `C`. 

# Examples
```jldoctest
julia> R, (x,y,z) = graded_polynomial_ring(QQ, ["x", "y", "z"]);

julia> C = ProjectivePlaneCurve(y^4-2*x^3*z+3*x^2*z^2-2*y^2*z^2)
Projective plane curve
  defined by 0 = 2*x^3*z - 3*x^2*z^2 - y^4 + 2*y^2*z^2

julia> I = adjoint_ideal(C)
ideal(-x*z + y^2, x*y - y*z, x^2 - x*z)

```
"""
function adjoint_ideal(C::ProjectivePlaneCurve{QQField})
    n = 2
    F = _tosingular(C)
    R = parent(defining_equation(C))
    I = Singular.LibParaplanecurves.adjointIdeal(F, n)
    return ideal(R, I)
end

@doc raw"""
    rational_point_conic(D::ProjectivePlaneCurve{QQField})

If the plane conic `D` contains a rational point, return the homogeneous coordinates of such a point.
If no such point exists, return a point on `D` defined over a quadratic field extension of $\mathbb Q$.
 
# Examples
```jldoctest
julia> R, (x,y,z) = graded_polynomial_ring(QQ, ["x", "y", "z"]);

julia> C = ProjectivePlaneCurve(y^4-2*x^3*z+3*x^2*z^2-2*y^2*z^2)
Projective plane curve
  defined by 0 = 2*x^3*z - 3*x^2*z^2 - y^4 + 2*y^2*z^2

julia> I = adjoint_ideal(C)
ideal(-x*z + y^2, x*y - y*z, x^2 - x*z)

julia> R, (x,y,z) = graded_polynomial_ring(QQ, ["x", "y", "z"]);

julia> D = ProjectivePlaneCurve(x^2 + 2*y^2 + 5*z^2 - 4*x*y + 3*x*z + 17*y*z);

julia> P = rational_point_conic(D)
3-element Vector{AbstractAlgebra.Generic.MPoly{nf_elem}}:
 -1//4*a
 -1//4*a + 1//4
 0

julia> S = parent(P[1])
Multivariate polynomial ring in 3 variables x, y, z
  over number field of degree 2 over QQ

julia> NF = base_ring(S)
Number field with defining polynomial t^2 - 2
  over rational field

julia> a = gen(NF)
a

julia> minpoly(a)
t^2 - 2

```
"""
function rational_point_conic(C::ProjectivePlaneCurve{QQField})
    F = _tosingular(C)
    L = Singular.LibParaplanecurves.rationalPointConic(F)
    R = L[1]
    P = [L[2][i] for i in keys(L[2])][1]
    S = _fromsingular_ring(R)
    return [S(P[1, i]) for i in 1:3]
end

@doc raw"""
    parametrization_conic(C::ProjectivePlaneCurve{QQField})

Given a plane conic `C`, return a vector `V` of polynomials in a new ring which should be
considered as the homogeneous coordinate ring of `PP^1`. The vector `V` defines a
rational parametrization `PP^1 --> C2 = {q=0}`.
"""
function parametrization_conic(C::ProjectivePlaneCurve{QQField})
    F = _tosingular(C)
    L = Singular.LibParaplanecurves.paraConic(F)
    R = L[1]
    J = [L[2][i] for i in keys(L[2])][1]
    S = _fromsingular_ring(R)
    return gens(ideal(S, J))
end

@doc raw"""
    map_to_rational_normal_curve(C::ProjectivePlaneCurve{QQField})

Return a rational normal curve of degree $\deg C-2$ which `C` is mapped to.

# Examples
```jldoctest
julia> R, (x,y,z) = graded_polynomial_ring(QQ, ["x", "y", "z"]);

julia> C = ProjectivePlaneCurve(y^4-2*x^3*z+3*x^2*z^2-2*y^2*z^2);

julia> geometric_genus(C)
0

julia> Oscar.map_to_rational_normal_curve(C)
Projective curve
  in projective 2-space over QQ with coordinates [y(1), y(2), y(3)]
defined by ideal(y(1)^2 + 2*y(1)*y(3) - 2*y(2)^2)

```
"""
function map_to_rational_normal_curve(C::ProjectivePlaneCurve{QQField})
    F = _tosingular(C)
    I = Singular.LibParaplanecurves.adjointIdeal(F)
    L = Singular.LibParaplanecurves.mapToRatNormCurve(F, I)
    S = _fromsingular_ring(L[1])
    J = [L[2][i] for i in keys(L[2])][1]
    R,_ = grade(S)
    IC = ideal(R, R.(gens(J)))
    return ProjectiveCurve(IC)
end


@doc raw"""
    rat_normal_curve_anticanonical_map(C::ProjectiveCurve)

Return a vector `V` defining the anticanonical map `C --> PP^(n-2)`. Note that the
entries of `V` should be considered as representatives of elements in R/I,
where R is the basering.

# Examples
```jldoctest
julia> R, (v, w, x, y, z) = graded_polynomial_ring(QQ, ["v", "w", "x", "y", "z"]);

julia> M = matrix(R, 2, 4, [v w x y; w x y z])
[v   w   x   y]
[w   x   y   z]

julia> V = minors(M, 2)
6-element Vector{MPolyDecRingElem{QQFieldElem, QQMPolyRingElem}}:
 v*x - w^2
 v*y - w*x
 w*y - x^2
 v*z - w*y
 w*z - x*y
 x*z - y^2

julia> I = ideal(R, V);

julia> RNC = ProjectiveCurve(I)
Projective curve
  in projective 4-space over QQ with coordinates [v, w, x, y, z]
defined by ideal(v*x - w^2, v*y - w*x, w*y - x^2, v*z - w*y, w*z - x*y, x*z - y^2)

julia> Oscar.rat_normal_curve_anticanonical_map(RNC)
3-element Vector{MPolyDecRingElem{QQFieldElem, QQMPolyRingElem}}:
 x
 -y
 z

```
"""
function rat_normal_curve_anticanonical_map(C::ProjectiveCurve)
    R = base_ring(fat_ideal(C))
    I = _tosingular_ideal(C)
    J = Singular.LibParaplanecurves.rncAntiCanonicalMap(I)
    return gens(ideal(R, J))
end

@doc raw"""
    rat_normal_curve_It_Proj_Odd(C::ProjectiveCurve)

Return a vector `PHI` defining an isomorphic projection of `C` to `PP^1`.
Note that the entries of `PHI` should be considered as
representatives of elements in `R/I`, where `R` is the basering.

# Examples
```jldoctest
julia> R, (w, x, y, z) = graded_polynomial_ring(QQ, ["w", "x", "y", "z"]);

julia> M = matrix(R, 2, 3, [w x y; x y z])
[w   x   y]
[x   y   z]

julia> V = minors(M, 2)
3-element Vector{MPolyDecRingElem{QQFieldElem, QQMPolyRingElem}}:
 w*y - x^2
 w*z - x*y
 x*z - y^2

julia> I = ideal(R, V);

julia> TC = ProjectiveCurve(I)
Projective curve
  in projective 3-space over QQ with coordinates [w, x, y, z]
defined by ideal(w*y - x^2, w*z - x*y, x*z - y^2)

julia> Oscar.rat_normal_curve_It_Proj_Odd(TC)
2-element Vector{MPolyDecRingElem{QQFieldElem, QQMPolyRingElem}}:
 y
 -z

```
"""
function rat_normal_curve_It_Proj_Odd(C::ProjectiveCurve)
    R = base_ring(fat_ideal(C))
    I = _tosingular_ideal(C)
    J = Singular.LibParaplanecurves.rncItProjOdd(I)
    return gens(ideal(R, J))
end

# lookup an ideal with name s in the symbol table
# TODO move this to Singular.jl
function _lookup_ideal(R::Singular.PolyRingUnion, s::Symbol)
    for i in Singular.libSingular.get_ring_content(R.ptr)
        if i[2] == s
            @assert i[1] == Singular.mapping_types_reversed[:IDEAL_CMD]
            ptr = Singular.libSingular.IDEAL_CMD_CASTER(i[3])
            ptr = Singular.libSingular.id_Copy(ptr, R.ptr)
            return Singular.sideal{elem_type(R)}(R, ptr)
        end
    end
    error("could not find PHI")
end

@doc raw"""
    rat_normal_curve_It_Proj_Even(C::ProjectiveCurve)

Return a vector `PHI` defining an isomorphic projection of `C` to `PP^1`.
Note that the entries of `PHI` should be considered as
representatives of elements in `R/I`, where `R` is the basering.

# Examples
```jldoctest
julia> R, (v, w, x, y, z) = graded_polynomial_ring(QQ, ["v", "w", "x", "y", "z"]);

julia> M = matrix(R, 2, 4, [v w x y; w x y z])
[v   w   x   y]
[w   x   y   z]

julia> V = minors(M, 2)
6-element Vector{MPolyDecRingElem{QQFieldElem, QQMPolyRingElem}}:
 v*x - w^2
 v*y - w*x
 w*y - x^2
 v*z - w*y
 w*z - x*y
 x*z - y^2

julia> I = ideal(R, V);

julia> RNC = ProjectiveCurve(I)
Projective curve
  in projective 4-space over QQ with coordinates [v, w, x, y, z]
defined by ideal(v*x - w^2, v*y - w*x, w*y - x^2, v*z - w*y, w*z - x*y, x*z - y^2)

julia> Oscar.rat_normal_curve_It_Proj_Even(RNC)
(MPolyDecRingElem{QQFieldElem, QQMPolyRingElem}[x, -y, z], V(y(1)*y(3) - y(2)^2))

```
"""
function rat_normal_curve_It_Proj_Even(C::ProjectiveCurve)
    R = base_ring(fat_ideal(C))
    I = _tosingular_ideal(C)
    L = Singular.LibParaplanecurves.rncItProjEven(I)
    phi = _lookup_ideal(base_ring(I), :PHI)
    O = _fromsingular_ring(L[1]::Singular.PolyRing)
    Ograded,_ = grade(O)
    conic = L[2][:CONIC]::Singular.spoly
    return gens(ideal(R, phi)), ProjectivePlaneCurve(Ograded(conic))
end

@doc raw"""
    invert_birational_map(phi::Vector{T}, C::ProjectivePlaneCurve) where {T <: MPolyRingElem}

Return a dictionary where `image` represents the image of the birational map
given by `phi`, and `inverse` represents its inverse, where `phi` is a
birational map of the projective plane curve `C` to its image in the projective
space of dimension `size(phi) - 1`.
Note that the entries of `inverse` should be considered as
representatives of elements in `R/image`, where `R` is the basering.
"""
function invert_birational_map(phi::Vector{T}, C::ProjectivePlaneCurve) where {T <: MPolyRingElem}
    S = parent(phi[1])
    I = ideal(S, phi)
    singular_assure(I)
    L = Singular.LibParaplanecurves.invertBirMap(I.gens.S, _tosingular(C))
    R = _fromsingular_ring(L[1])
    J = L[2][:J]
    psi = L[2][:psi]
    return Dict([("image", gens(ideal(R, J))), ("inverse", gens(ideal(R, psi)))])
end
