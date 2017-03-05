(*
 * OWL - an OCaml numerical library for scientific computing
 * Copyright (c) 2016-2017 Liang Wang <liang.wang@cl.cam.ac.uk>
 *)

open Owl_ext_types

(* trivial cases *)

module F_F = struct

  module M = Pervasives

  let ( + ) x y = F M.(x +. y)
  let ( - ) x y = F M.(x -. y)
  let ( * ) x y = F M.(x *. y)
  let ( / ) x y = F M.(x /. y)

end


module F_C = struct

  module M = Complex

  let ( + ) x y = C M.(add {re = x; im = 0.} y)
  let ( - ) x y = C M.(sub {re = x; im = 0.} y)
  let ( * ) x y = C M.(mul {re = x; im = 0.} y)
  let ( / ) x y = C M.(add {re = x; im = 0.} y)

end


module C_F = struct

  module M = Complex

  let ( + ) x y = C M.(add x {re = y; im = 0.})
  let ( - ) x y = C M.(sub x {re = y; im = 0.})
  let ( * ) x y = C M.(mul x {re = y; im = 0.})
  let ( / ) x y = C M.(div x {re = y; im = 0.})

end


module C_C = struct

  module M = Complex

  let ( + ) x y = C M.(add x y)
  let ( - ) x y = C M.(sub x y)
  let ( * ) x y = C M.(mul x y)
  let ( / ) x y = C M.(div x y)

end

(* float numbers, no lift *)

module F_DAS = struct

  module M = Owl_ext_dense_ndarray.S

  let ( + ) a x = M.add_scalar x a
  let ( - ) a x = M.(sub_scalar x a |> neg)
  let ( * ) a x = M.mul_scalar x a
  let ( / ) a x = M.(mul_scalar (reci x) a)

end


module DAS_F = struct

  module M = Owl_ext_dense_ndarray.S

  let ( + ) x a = M.add_scalar x a
  let ( - ) x a = M.sub_scalar x a
  let ( * ) x a = M.mul_scalar x a
  let ( / ) x a = M.div_scalar x a

end


module DAS_DAS = struct

  module M = Owl_ext_dense_ndarray.S

  let ( + ) x y = M.add x y
  let ( - ) x y = M.sub x y
  let ( * ) x y = M.mul x y
  let ( / ) x y = M.div x y

end


module F_DAD = struct

  module M = Owl_ext_dense_ndarray.D

  let ( + ) a x = M.add_scalar x a
  let ( - ) a x = M.(sub_scalar x a |> neg)
  let ( * ) a x = M.mul_scalar x a
  let ( / ) a x = M.(mul_scalar (reci x) a)

end


module DAD_F = struct

  module M = Owl_ext_dense_ndarray.D

  let ( + ) x a = M.add_scalar x a
  let ( - ) x a = M.sub_scalar x a
  let ( * ) x a = M.mul_scalar x a
  let ( / ) x a = M.div_scalar x a

end


module DAD_DAD = struct

  module M = Owl_ext_dense_ndarray.D

  let ( + ) x y = M.add x y
  let ( - ) x y = M.sub x y
  let ( * ) x y = M.mul x y
  let ( / ) x y = M.div x y

end


module F_DMS = struct

  module M = Owl_ext_dense_matrix.S

  let ( + ) a x = M.add_scalar x a
  let ( - ) a x = M.(sub_scalar x a |> neg)
  let ( * ) a x = M.mul_scalar x a
  let ( / ) a x = M.(mul_scalar (reci x) a)

end


module DMS_F = struct

  module M = Owl_ext_dense_matrix.S

  let ( + ) x a = M.add_scalar x a
  let ( - ) x a = M.sub_scalar x a
  let ( * ) x a = M.mul_scalar x a
  let ( / ) x a = M.div_scalar x a

end


module DMS_DMS = struct

  module M = Owl_ext_dense_matrix.S

  let ( + ) x y = M.add x y
  let ( - ) x y = M.sub x y
  let ( * ) x y = M.mul x y
  let ( / ) x y = M.div x y

end


module F_DMD = struct

  module M = Owl_ext_dense_matrix.D

  let ( + ) a x = M.add_scalar x a
  let ( - ) a x = M.(sub_scalar x a |> neg)
  let ( * ) a x = M.mul_scalar x a
  let ( / ) a x = M.(mul_scalar (reci x) a)

end


module DMD_F = struct

  module M = Owl_ext_dense_matrix.D

  let ( + ) x a = M.add_scalar x a
  let ( - ) x a = M.sub_scalar x a
  let ( * ) x a = M.mul_scalar x a
  let ( / ) x a = M.div_scalar x a

end


module DMD_DMD = struct

  module M = Owl_ext_dense_matrix.D

  let ( + ) x y = M.add x y
  let ( - ) x y = M.sub x y
  let ( * ) x y = M.mul x y
  let ( / ) x y = M.div x y

end

(* complex numbers, no lift *)

module C_DAC = struct

  module M = Owl_ext_dense_ndarray.C

  let ( + ) a x = M.add_scalar x a
  let ( - ) a x = M.(sub_scalar x a |> neg)
  let ( * ) a x = M.mul_scalar x a
  let ( / ) a x = M.(mul_scalar (reci x) a)

end


module DAC_C = struct

  module M = Owl_ext_dense_ndarray.C

  let ( + ) x a = M.add_scalar x a
  let ( - ) x a = M.sub_scalar x a
  let ( * ) x a = M.mul_scalar x a
  let ( / ) x a = M.div_scalar x a

end


module DAC_DAC = struct

  module M = Owl_ext_dense_ndarray.C

  let ( + ) x y = M.add x y
  let ( - ) x y = M.sub x y
  let ( * ) x y = M.mul x y
  let ( / ) x y = M.div x y

end


module C_DAZ = struct

  module M = Owl_ext_dense_ndarray.Z

  let ( + ) a x = M.add_scalar x a
  let ( - ) a x = M.(sub_scalar x a |> neg)
  let ( * ) a x = M.mul_scalar x a
  let ( / ) a x = M.(mul_scalar (reci x) a)

end


module DAZ_C = struct

  module M = Owl_ext_dense_ndarray.Z

  let ( + ) x a = M.add_scalar x a
  let ( - ) x a = M.sub_scalar x a
  let ( * ) x a = M.mul_scalar x a
  let ( / ) x a = M.div_scalar x a

end


module DAZ_DAZ = struct

  module M = Owl_ext_dense_ndarray.Z

  let ( + ) x y = M.add x y
  let ( - ) x y = M.sub x y
  let ( * ) x y = M.mul x y
  let ( / ) x y = M.div x y

end


module C_DMC = struct

  module M = Owl_ext_dense_matrix.C

  let ( + ) a x = M.add_scalar x a
  let ( - ) a x = M.(sub_scalar x a |> neg)
  let ( * ) a x = M.mul_scalar x a
  let ( / ) a x = M.(mul_scalar (reci x) a)

end


module DMC_C = struct

  module M = Owl_ext_dense_matrix.C

  let ( + ) x a = M.add_scalar x a
  let ( - ) x a = M.sub_scalar x a
  let ( * ) x a = M.mul_scalar x a
  let ( / ) x a = M.div_scalar x a

end


module DMC_DMC = struct

  module M = Owl_ext_dense_matrix.C

  let ( + ) x y = M.add x y
  let ( - ) x y = M.sub x y
  let ( * ) x y = M.mul x y
  let ( / ) x y = M.div x y

end


module C_DMZ = struct

  module M = Owl_ext_dense_matrix.Z

  let ( + ) a x = M.add_scalar x a
  let ( - ) a x = M.(sub_scalar x a |> neg)
  let ( * ) a x = M.mul_scalar x a
  let ( / ) a x = M.(mul_scalar (reci x) a)

end


module DMZ_C = struct

  module M = Owl_ext_dense_matrix.Z

  let ( + ) x a = M.add_scalar x a
  let ( - ) x a = M.sub_scalar x a
  let ( * ) x a = M.mul_scalar x a
  let ( / ) x a = M.div_scalar x a

end


module DMZ_DMZ = struct

  module M = Owl_ext_dense_matrix.Z

  let ( + ) x y = M.add x y
  let ( - ) x y = M.sub x y
  let ( * ) x y = M.mul x y
  let ( / ) x y = M.div x y

end


(* float/complex, lift precision *)

module DAS_DAD = struct

  module M = Owl_ext_dense_ndarray.D
  let lift = Owl_ext_lifts.DAS_DAD.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DAD_DAS = struct

  module M = Owl_ext_dense_ndarray.D
  let lift = Owl_ext_lifts.DAS_DAD.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module DAC_DAZ = struct

  module M = Owl_ext_dense_ndarray.Z
  let lift = Owl_ext_lifts.DAC_DAZ.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DAZ_DAC = struct

  module M = Owl_ext_dense_ndarray.Z
  let lift = Owl_ext_lifts.DAC_DAZ.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module DMS_DMD = struct

  module M = Owl_ext_dense_matrix.D
  let lift = Owl_ext_lifts.DMS_DMD.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DMD_DMS = struct

  module M = Owl_ext_dense_matrix.D
  let lift = Owl_ext_lifts.DMS_DMD.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module DMC_DMZ = struct

  module M = Owl_ext_dense_matrix.Z
  let lift = Owl_ext_lifts.DMC_DMZ.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DMZ_DMC = struct

  module M = Owl_ext_dense_matrix.Z
  let lift = Owl_ext_lifts.DMC_DMZ.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


(* float -> complex, lift number type *)

module F_DAC = struct

  module M = Owl_ext_dense_ndarray.C
  let lift = Owl_ext_lifts.F_C.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DAC_F = struct

  module M = Owl_ext_dense_ndarray.C
  let lift = Owl_ext_lifts.F_C.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module F_DAZ = struct

  module M = Owl_ext_dense_ndarray.Z
  let lift = Owl_ext_lifts.F_C.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DAZ_F = struct

  module M = Owl_ext_dense_ndarray.Z
  let lift = Owl_ext_lifts.F_C.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module C_DAS = struct

  module M = Owl_ext_dense_ndarray.C
  let lift = Owl_ext_lifts.DAS_DAC.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DAS_C = struct

  module M = Owl_ext_dense_ndarray.C
  let lift = Owl_ext_lifts.DAS_DAC.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module C_DAD = struct

  module M = Owl_ext_dense_ndarray.Z
  let lift = Owl_ext_lifts.DAD_DAZ.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DAD_C = struct

  module M = Owl_ext_dense_ndarray.Z
  let lift = Owl_ext_lifts.DAD_DAZ.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module DAS_DAC = struct

  module M = Owl_ext_dense_ndarray.C
  let lift = Owl_ext_lifts.DAS_DAC.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DAC_DAS = struct

  module M = Owl_ext_dense_ndarray.C
  let lift = Owl_ext_lifts.DAS_DAC.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module DAD_DAZ = struct

  module M = Owl_ext_dense_ndarray.Z
  let lift = Owl_ext_lifts.DAD_DAZ.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DAZ_DAD = struct

  module M = Owl_ext_dense_ndarray.Z
  let lift = Owl_ext_lifts.DAD_DAZ.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module F_DMC = struct

  module M = Owl_ext_dense_matrix.C
  let lift = Owl_ext_lifts.F_C.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DMC_F = struct

  module M = Owl_ext_dense_matrix.C
  let lift = Owl_ext_lifts.F_C.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module F_DMZ = struct

  module M = Owl_ext_dense_matrix.Z
  let lift = Owl_ext_lifts.F_C.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DMZ_F = struct

  module M = Owl_ext_dense_matrix.Z
  let lift = Owl_ext_lifts.F_C.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module C_DMS = struct

  module M = Owl_ext_dense_matrix.C
  let lift = Owl_ext_lifts.DMS_DMC.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DMS_C = struct

  module M = Owl_ext_dense_matrix.C
  let lift = Owl_ext_lifts.DMS_DMC.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module C_DMD = struct

  module M = Owl_ext_dense_matrix.Z
  let lift = Owl_ext_lifts.DMD_DMZ.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DMD_C = struct

  module M = Owl_ext_dense_matrix.Z
  let lift = Owl_ext_lifts.DMD_DMZ.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module DMS_DMC = struct

  module M = Owl_ext_dense_matrix.C
  let lift = Owl_ext_lifts.DMS_DMC.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DMC_DMS = struct

  module M = Owl_ext_dense_matrix.C
  let lift = Owl_ext_lifts.DMS_DMC.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module DMD_DMZ = struct

  module M = Owl_ext_dense_matrix.Z
  let lift = Owl_ext_lifts.DMD_DMZ.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DMZ_DMD = struct

  module M = Owl_ext_dense_matrix.Z
  let lift = Owl_ext_lifts.DMD_DMZ.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


(* float -> complex, lift both precision and number type *)

module DAS_DAZ = struct

  module M = Owl_ext_dense_ndarray.Z
  let lift = Owl_ext_lifts.DAS_DAZ.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DAZ_DAS = struct

  module M = Owl_ext_dense_ndarray.Z
  let lift = Owl_ext_lifts.DAS_DAZ.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


module DMS_DMZ = struct

  module M = Owl_ext_dense_matrix.Z
  let lift = Owl_ext_lifts.DMS_DMZ.lift

  let ( + ) x y = M.add (lift x) y
  let ( - ) x y = M.sub (lift x) y
  let ( * ) x y = M.mul (lift x) y
  let ( / ) x y = M.div (lift x) y

end


module DMZ_DMS = struct

  module M = Owl_ext_dense_matrix.Z
  let lift = Owl_ext_lifts.DMS_DMZ.lift

  let ( + ) x y = M.add x (lift y)
  let ( - ) x y = M.sub x (lift y)
  let ( * ) x y = M.mul x (lift y)
  let ( / ) x y = M.div x (lift y)

end


(* overload binary operators *)

let ( + ) x y = match x, y with
  | F x, F y     -> F_F.(x + y)
  | F x, C y     -> F_C.(x + y)
  | C x, F y     -> C_F.(x + y)
  | C x, C y     -> C_C.(x + y)
  | F _, DAS _   -> F_DAS.(x + y)
  | DAS _, F _   -> DAS_F.(x + y)
  | DAS _, DAS _ -> DAS_DAS.(x + y)
  | F _, DAD _   -> F_DAD.(x + y)
  | DAD _, F _   -> DAD_F.(x + y)
  | DAD _, DAD _ -> DAD_DAD.(x + y)
  | F _, DMS _   -> F_DMS.(x + y)
  | DMS _, F _   -> DMS_F.(x + y)
  | DMS _, DMS _ -> DMS_DMS.(x + y)
  | F _, DMD _   -> F_DMD.(x + y)
  | DMD _, F _   -> DMD_F.(x + y)
  | DMD _, DMD _ -> DMD_DMD.(x + y)
  | C _, DAC _   -> C_DAC.(x + y)
  | DAC _, C _   -> DAC_C.(x + y)
  | DAC _, DAC _ -> DAC_DAC.(x + y)
  | C _, DAZ _   -> C_DAZ.(x + y)
  | DAZ _, C _   -> DAZ_C.(x + y)
  | DAZ _, DAZ _ -> DAZ_DAZ.(x + y)
  | C _, DMC _   -> C_DMC.(x + y)
  | DMC _, C _   -> DMC_C.(x + y)
  | DMC _, DMC _ -> DMC_DMC.(x + y)
  | C _, DMZ _   -> C_DMZ.(x + y)
  | DMZ _, C _   -> DMZ_C.(x + y)
  | DMZ _, DMZ _ -> DMZ_DMZ.(x + y)
  | _ -> failwith "( + ) : unknown type"



(* ends here *)
