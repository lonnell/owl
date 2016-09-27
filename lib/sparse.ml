(** [ Sparse matrix support ] *)

open Bigarray
open Types

type spmat = spmat_record

let _empty_int_array () = Array1.create int64 c_layout 0

let _of_sp_mat_ptr p =
  let open Matrix_foreign in
  let open Ctypes in
  let y = !@ p in
  let tz = Int64.to_int (getf y sp_nz) in
  let ty = Int64.to_int (getf y sp_type) in
  let tm = Int64.to_int (getf y sp_size1) in
  let tn = Int64.to_int (getf y sp_size2) in
  let ti = bigarray_of_ptr array1 tz Bigarray.int64 (getf y sp_i) in
  let td = bigarray_of_ptr array1 tz Bigarray.float64 (getf y sp_data) in
  (** note: p array has different length in triplet and csc format *)
  let pl = if ty = 0 then tz else tn + 1 in
  let tp = bigarray_of_ptr array1 pl Bigarray.int64 (getf y sp_p) in
  { m = tm; n = tn; i = ti; d = td; p = tp; nz = tz; typ = ty; ptr = p; }

let _update_rec_from_ptr x =
  let open Matrix_foreign in
  let open Ctypes in
  let y = !@ (x.ptr) in
  let _ = x.typ <- Int64.to_int (getf y sp_type) in
  let _ = x.m <- Int64.to_int (getf y sp_size1) in
  let _ = x.n <- Int64.to_int (getf y sp_size2) in
  let _ = x.nz <- Int64.to_int (getf y sp_nz) in
  let _ = x.i <- (bigarray_of_ptr array1 x.nz Bigarray.int64 (getf y sp_i)) in
  let _ = x.d <- (bigarray_of_ptr array1 x.nz Bigarray.float64 (getf y sp_data)) in
  (* note: p array has different length in triplet and csc format *)
  let pl = if x.typ = 0 then x.nz else x.n + 1 in
  let _ = x.p <- (bigarray_of_ptr array1 pl Bigarray.int64 (getf y sp_p)) in
  x

let _update_rec_after_set x =
  let open Matrix_foreign in
  let open Ctypes in
  let y = !@ (x.ptr) in
  let _ = x.nz <- Int64.to_int (getf y sp_nz) in x

let _is_csc_format x = x.typ = 1

let allocate_vecptr m =
  let open Matrix_foreign in
  let open Ctypes in
  let p = gsl_vector_alloc m in
  let y = !@ p in
  let x = {
    vsize = Int64.to_int (getf y vsize);
    stride = Int64.to_int (getf y vsize);
    vdata = (
      let raw = getf y vdata in
      bigarray_of_ptr array2 (1,m) Bigarray.float64 raw );
    vptr = p } in x


(** sparse matrix creation function *)

let empty m n =
  let open Matrix_foreign in
  let x = gsl_spmatrix_alloc m n in
  _of_sp_mat_ptr x

let empty_csc m n =
  let open Matrix_foreign in
  let c = int_of_float ((float_of_int (m * n)) *. 0.1) in
  let c = Pervasives.max 10 c in
  let x = gsl_spmatrix_alloc_nzmax m n c 1 in
  _of_sp_mat_ptr x

let set x i j y =
  (* FIXME: must be in triplet form; _update_rec_after_set *)
  let open Matrix_foreign in
  let _ = gsl_spmatrix_set x.ptr i j y in
  let _ = _update_rec_after_set x in ()

let set_without_update_rec x i j y =
  let open Matrix_foreign in
  let _ = gsl_spmatrix_set x.ptr i j y in ()

let get x i j =
  let open Matrix_foreign in
  gsl_spmatrix_get x.ptr i j

let reset x =
  let open Matrix_foreign in
  let _ = (gsl_spmatrix_set_zero x.ptr) in
  let _ = _update_rec_from_ptr x in ()

let shape x = x.m, x.n

let row_num x = x.m

let col_num x = x.n

let nnz x = x.nz

let density x =
  let m, n, c = row_num x, col_num x, nnz x in
  (float_of_int c) /. (float_of_int (m * n))

let eye n =
  let x = empty n n in
  for i = 0 to (row_num x) - 1 do
      set_without_update_rec x i i 1.
  done;
  _update_rec_from_ptr x

let uniform_int ?(a=0) ?(b=99) m n =
  let c = int_of_float ((float_of_int (m * n)) *. 0.1) in
  let x = empty m n in
  for k = 0 to c do
    let i = Stats.uniform_int ~a:0 ~b:(m-1) () in
    let j = Stats.uniform_int ~a:0 ~b:(n-1) () in
    set_without_update_rec x i j (float_of_int (Stats.uniform_int ~a ~b ()))
  done;
  _update_rec_from_ptr x

let uniform ?(scale=1.) m n =
  let c = int_of_float ((float_of_int (m * n)) *. 0.1) in
  let x = empty m n in
  for k = 0 to c do
    let i = Stats.uniform_int ~a:0 ~b:(m-1) () in
    let j = Stats.uniform_int ~a:0 ~b:(n-1) () in
    set_without_update_rec x i j (Stats.uniform () *. scale)
  done;
  _update_rec_from_ptr x


(** matrix manipulations *)

let copy_to x1 x2 =
  let open Matrix_foreign in
  let _ = gsl_spmatrix_memcpy x2.ptr x1.ptr in
  _update_rec_from_ptr x2

let to_csc x =
  let open Matrix_foreign in
  let m, n = shape x in
  match _is_csc_format x with
  | true  -> let y = empty_csc m n in copy_to x y
  | false -> let p = gsl_spmatrix_compcol x.ptr in _of_sp_mat_ptr p

let transpose x =
  let open Matrix_foreign in
  let y = if _is_csc_format x
    then empty_csc (col_num x) (row_num x)
    else empty (col_num x) (row_num x) in
  let _ = gsl_spmatrix_transpose_memcpy y.ptr x.ptr in
  _update_rec_from_ptr y

(* matrix interation functions *)

let row x i =
  let y = empty 1 (col_num x) in
  for j = 0 to (col_num x) - 1 do
    set_without_update_rec y 0 j (get x i j)
  done;
  _update_rec_from_ptr y

let col x i =
  let y = empty (row_num x) 1 in
  for j = 0 to (row_num x) - 1 do
    set_without_update_rec y j 0 (get x j i)
  done;
  _update_rec_from_ptr y

let rows x l =
  let m, n = Array.length l, col_num x in
  let y = empty m n in
  Array.iteri (fun i i' ->
    for j = 0 to n - 1 do
      set_without_update_rec y i j (get x i' j)
    done
  ) l;
  _update_rec_from_ptr y

let cols x l =
  let m, n = row_num x, Array.length l in
  let y = empty m n in
  Array.iteri (fun j j' ->
    for i = 0 to m - 1 do
      set_without_update_rec y i j (get x i j')
    done
  ) l;
  _update_rec_from_ptr y

let iteri f x =
  for i = 0 to (row_num x) - 1 do
    for j = 0 to (col_num x) - 1 do
      f i j (get x i j)
    done
  done

let iter f x = iteri (fun _ _ y -> f y) x

let mapi f x =
  (** note: if f returns zero, no actual value will be added into sparse matrix. *)
  let y = empty (row_num x) (col_num x) in
  iteri (fun i j z -> set_without_update_rec y i j (f i j z)) x;
  _update_rec_from_ptr y

let map f x = mapi (fun _ _ y -> f y) x

let _fold_basic iter_fun f a x =
  let r = ref a in
  iter_fun (fun y -> r := f !r y) x; !r

let fold f a x = _fold_basic iter f a x

let filteri f x =
  let r = ref [||] in
  iteri (fun i j y ->
    if (f i j y) then r := Array.append !r [|(i,j)|]
  ) x; !r

let filter f x = filteri (fun _ _ y -> f y) x

let iteri_rows f x =
  for i = 0 to (row_num x) - 1 do
    f i (row x i)
  done

let iter_rows f x = iteri_rows (fun _ y -> f y) x

let iteri_cols f x =
  for j = 0 to (col_num x) - 1 do
    f j (col x j)
  done

let iter_cols f x = iteri_cols (fun _ y -> f y) x

let iteri_nz f x =
  let x = if _is_csc_format x then x else to_csc x in
  for j = 0 to x.n - 1 do
    for k = Int64.to_int (Array1.get x.p j) to (Int64.to_int (Array1.get x.p (j + 1))) - 1 do
      let i = Int64.to_int (Array1.get x.i k) in
      let y = Array1.get x.d k in
      f i j y
    done
  done

let iter_nz f x = iteri_nz (fun _ _ y -> f y) x

let mapi_nz f x =
  let x = if _is_csc_format x then x else to_csc x in
  let y = empty_csc (row_num x) (col_num x) in
  let _ = copy_to x y in
  for j = 0 to y.n - 1 do
    for k = Int64.to_int (Array1.get y.p j) to (Int64.to_int (Array1.get y.p (j + 1))) - 1 do
      let i = Int64.to_int (Array1.get y.i k) in
      let z = Array1.get y.d k in
      Array1.set y.d k (f i j z)
    done
  done; y

let map_nz f x = mapi_nz (fun _ _ y -> f y) x

let fold_nz f a x = _fold_basic iter_nz f a x

let filteri_nz f x =
  let r = ref [||] in
  iteri_nz (fun i j y ->
    if (f i j y) then r := Array.append !r [|(i,j)|]
  ) x; !r

let filter_nz f x = filteri_nz (fun _ _ y -> f y) x

let mapi_rows f x =
  let m = row_num x in
  let n = col_num (f 0 (row x 0)) in
  let y = empty m n in
  iteri_rows (fun i r ->
    iteri_nz (fun _ j z -> set_without_update_rec y i j z) r
  ) x;
  _update_rec_from_ptr y

let mapi_cols f x =
  let m = row_num (f 0 (col x 0)) in
  let n = col_num x in
  let y = empty m n in
  iteri_cols (fun j c ->
    iteri_nz (fun i _ z -> set_without_update_rec y i j z) c
  ) x;
  _update_rec_from_ptr y

let fold_rows f a x = _fold_basic iter_rows f a x

let fold_cols f a x = _fold_basic iter_cols f a x

let iteri_rows_nz f x =
  iteri_rows (fun i r ->
    match r.nz = 0 with true  -> () | false -> f i r
  ) x

let iter_rows_nz f x = iteri_rows_nz (fun _ y -> f y) x

let iteri_cols_nz f x =
  iteri_cols (fun j c ->
    match c.nz = 0 with true  -> () | false -> f j c
  ) x

let iter_cols_nz f x = iteri_cols_nz (fun _ y -> f y) x

let mapi_rows_nz = None

let mapi_cols_nz = None

let fold_rows_nz f a x = _fold_basic iter_rows_nz f a x

let fold_cols_nz f a x = _fold_basic iter_cols_nz f a x

let _exists_basic iter_fun f x =
  try iter_fun (fun y ->
    if (f y) = true then failwith "found"
  ) x; false
  with exn -> true

let exists f x = _exists_basic iter f x

let not_exists f x = not (exists f x)

let for_all f x = let g y = not (f y) in not_exists g x

let exists_nz f x = _exists_basic iter_nz f x

let not_exists_nz f x = not (exists_nz f x)

let for_all_nz f x = let g y = not (f y) in not_exists_nz g x

let clone x =
  let y = empty (row_num x) (col_num x) in
  match _is_csc_format x with
  | true  -> iteri_nz (fun i j z -> set_without_update_rec y i j z) x; _update_rec_from_ptr y
  | false -> copy_to x y

(** matrix mathematical operations *)

let mul_scalar x1 y =
  let open Matrix_foreign in
  let x2 = to_csc x1 in
  let _ = gsl_spmatrix_scale x2.ptr y in
  x2

let div_scalar x1 y = mul_scalar x1 (1. /. y)

let add x1 x2 =
  let open Matrix_foreign in
  let x1 = if _is_csc_format x1 then x1 else to_csc x1 in
  let x2 = if _is_csc_format x2 then x2 else to_csc x2 in
  let x3 = empty_csc (row_num x1) (col_num x1) in
  let _ = gsl_spmatrix_add x3.ptr x1.ptr x2.ptr in
  _update_rec_from_ptr x3

let dot x1 x2 =
  let open Matrix_foreign in
  let x1 = if _is_csc_format x1 then x1 else to_csc x1 in
  let x2 = if _is_csc_format x2 then x2 else to_csc x2 in
  let x3 = empty_csc (row_num x1) (col_num x2) in
  let _ = gsl_spblas_dgemm 1.0 x1.ptr x2.ptr x3.ptr in
  _update_rec_from_ptr x3

let sub x1 x2 =
  let x2 = mul_scalar x2 (-1.) in
  add x1 x2

let mul x1 x2 =
  match (nnz x1) < (nnz x2) with
  | true  -> mapi_nz (fun i j y -> (get x2 i j) *. y) x1
  | false -> mapi_nz (fun i j y -> (get x1 i j) *. y) x2

let div x1 x2 =
  mapi_nz (fun i j y ->
    let z = get x2 i j in
    if z = 0. then 0. else (y /. z)
  ) x1

let abs x = map_nz (abs_float) x

let neg x = mul_scalar x (-1.)

let sum x = fold_nz (+.) 0. x

let average x = (sum x) /. (float_of_int (x.m * x.n))

let power x c = map_nz (fun y -> y ** c) x

let is_zero x = x.nz = 0

let is_positive x =
  if x.nz < (x.m * x.n) then false
  else for_all (( < ) 0.) x

let is_negative x =
  if x.nz < (x.m * x.n) then false
  else for_all (( > ) 0.) x

let is_nonnegative x =
  for_all_nz (( <= ) 0.) x

let minmax x =
  let open Matrix_foreign in
  let open Ctypes in
  let xmin = allocate double 0. in
  let xmax = allocate double 0. in
  let _ = gsl_spmatrix_minmax x.ptr xmin xmax in
  !@ xmin, !@ xmax

let min x = fst (minmax x)

let max x = snd (minmax x)

let is_equal x1 x2 =
  let open Matrix_foreign in
  let x2 = match (_is_csc_format x1), (_is_csc_format x2) with
    | true, false -> to_csc x2
    | false, true -> clone x2
    | _ -> x2
  in (gsl_spmatrix_equal x1.ptr x2.ptr) = 1

let is_unequal x1 x2 = not (is_equal x1 x2)

let is_greater x1 x2 = is_positive (sub x1 x2)

let is_smaller x1 x2 = is_greater x2 x1

let equal_or_greater x1 x2 = is_nonnegative (sub x1 x2)

let equal_or_smaller x1 x2 = equal_or_greater x2 x1

(** advanced matrix methematical operations *)

let diag x =
  let m = Pervasives.min (row_num x) (col_num x) in
  let y = empty 1 m in
  iteri_nz (fun i j z ->
    if i = j then set y 0 j z else ()
  ) x; y

let trace x = sum (diag x)

let svd x = None

let qr x = None

let lu x = None

(** transform to and from different types *)

let to_dense x =
  let open Matrix_foreign in
  let x = if _is_csc_format x then clone x else x in
  let y = gsl_matrix_alloc (row_num x) (col_num x) in
  let _ = gsl_spmatrix_sp2d y x.ptr in
  matptr_to_mat y (row_num x) (col_num x)

let of_dense x =
  let open Matrix_foreign in
  let y = empty (Array2.dim1 x) (Array2.dim2 x) in
  let _ = gsl_spmatrix_d2sp y.ptr (mat_to_matptr x) in
  _update_rec_from_ptr y

(** formatted input / output operations *)

let print x =
  for i = 0 to (row_num x) - 1 do
    for j = 0 to (col_num x) - 1 do
      Printf.printf "%.2f " (get x i j)
    done;
    print_endline ""
  done

let pp_spmat x =
  let m, n = shape x in
  let c = nnz x in
  let p = 100. *. (density x) in
  let _ = if m < 100 && n < 100 then Dense.pp_dsmat (to_dense x) in
  Printf.printf "shape = (%i,%i); nnz = %i (%.1f%%)\n" m n c p

(** some other uncategorised functions *)

let permutation_matrix d =
  let l = Array.init d (fun x -> x) |> Stats.shuffle in
  let y = empty d d in
  let _ = Array.iteri (fun i j -> set y i j 1.) l in y

let draw_rows ?(replacement=true) x c =
  let m, n = shape x in
  let a = Array.init m (fun x -> x) |> Stats.shuffle in
  let l = match replacement with
    | true  -> Stats.sample a c
    | false -> Stats.choose a c
  in
  let y = empty c m in
  let _ = Array.iteri (fun i j -> set y i j 1.) l in
  dot y x

let draw_cols ?(replacement=true) x c =
  let m, n = shape x in
  let a = Array.init n (fun x -> x) |> Stats.shuffle in
  let l = match replacement with
    | true  -> Stats.sample a c
    | false -> Stats.choose a c
  in
  let y = empty n c in
  let _ = Array.iteri (fun j i -> set y i j 1.) l in
  dot x y

let shuffle_rows x =
  let y = permutation_matrix (row_num x) in dot y x

let shuffle_cols x =
  let y = permutation_matrix (col_num x) in dot x y

let shuffle x = x |> shuffle_rows |> shuffle_cols

(** short-hand infix operators *)

let ( +@ ) = add

let ( -@ ) = sub

let ( *@ ) = mul

let ( /@ ) = div

let ( $@ ) = dot

let ( **@ ) = power

let ( *$ ) x a = mul_scalar x a

let ( $* ) a x = mul_scalar x a

let ( /$ ) x a = div_scalar x a

let ( $/ ) a x = div_scalar x a

let ( =@ ) = is_equal

let ( >@ ) = is_greater

let ( <@ ) = is_smaller

let ( <>@ ) = is_unequal

let ( >=@ ) = equal_or_greater

let ( <=@ ) = equal_or_smaller




(** TODO: out of OCaml GC, need to release the memory, refer to gsl_multifit_nlin.ml file. *)




(** ends here *)
