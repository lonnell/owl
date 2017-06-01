(*
 * OWL - an OCaml numerical library for scientific computing
 * Copyright (c) 2016-2017 Liang Wang <liang.wang@cl.cam.ac.uk>
 *)

open Owl_algodiff.S
open Owl_neural_neuron


(* graph network and node definition *)

type node = {
  mutable id      : int;
  mutable prev    : node array;
  mutable next    : node array;
  mutable neuron  : neuron;
  mutable output  : t option;
  mutable network : network;
}
and network = {
  mutable size : int;         (* size of the graph network *)
  mutable root : node option; (* root of the graph network, i.e. input *)
  mutable topo : node array;  (* nodes sorted in topological order *)
}


(* functions to manipulate the network *)


(* TODO: topological sort the nodes in a graph network, Kahn's algorithm *)
let topological_sort n =
  let l = Owl_utils.Stack.make () in
  let s = Owl_utils.Stack.make () in
  Owl_utils.Stack.push s n;
  while Owl_utils.Stack.is_empty s = false do
    let n = Owl_utils.Stack.pop s in
    Owl_utils.Stack.push l n;
    (* TODO *)
  done;
  Owl_utils.Stack.to_array l


(* BFS iterate the nodes, apply [f : node -> unit] to each node *)
let rec bfs_iter f x =
  match x with
  | []     -> ()
  | hd::tl -> (
      let _ = f hd in
      let new_tl = tl @ (Array.to_list hd.next) in
      bfs_iter f new_tl
    )


(* BFS map the nodes, apply [f : node -> 'a] then return ['a array] *)
let bfs_map f x =
  let stack = Owl_utils.Stack.make () in
  bfs_iter (fun n ->
    Owl_utils.Stack.push stack (f n)
  ) x;
  Owl_utils.Stack.to_array stack


(* convert nn to array, the order is in BFS order *)
let bfs_array x = bfs_map (fun n -> n) x


let make_network size root topo = { size; root; topo; }


let make_node id prev next neuron output network = {
  id;
  prev;
  next;
  neuron;
  output;
  network;
}


let get_root nn =
  match nn.root with
  | Some n -> n
  | None   -> failwith "Owl_neural_graph:get_root"


let get_network n = n.network


(* collect the outputs of a given set of nodes *)
let collect_output nodes =
  Array.map (fun n ->
    match n.output with
    | Some o -> o
    | None   -> failwith "Owl_neural_graph:collect_output"
  ) nodes


let connect_pair prev next =
  assert (Array.mem prev next.prev = false);
  assert (Array.mem next prev.next = false);
  next.prev <- Array.append next.prev [|prev|];
  prev.next <- Array.append prev.next [|next|]


let connect_to_parents parents child =
  (* validate input and output have consistent shape *)
  (match child.neuron with
  | Dot _ -> (
      (* for dot neuron, two matrices must have [*,m][m,n] shape *)
      let shp0 = parents.(0).neuron |> get_out_shape in
      let shp1 = parents.(1).neuron |> get_out_shape in
      (* update the child's output shape *)
      connect [|shp0.(0); shp1.(1)|] child.neuron;
    )
  | _     -> (
      (* for other cases, all inputs must have the same shape *)
      let shp = parents.(0).neuron |> get_out_shape in
      Array.iter (fun n ->
        let shp' = n.neuron |> get_out_shape in
        assert (shp = shp');
      ) parents;
      (* update the child's output shape *)
      connect shp child.neuron;
    ));
  (* connect the child to the parents *)
  Array.iter (fun p ->
    connect_pair p child
  ) parents


(* add child node to nn and connect to parents *)
let rec add_node ?act_typ nn parents child =
  child.id <- nn.size;
  nn.size <- nn.size + 1;
  connect_to_parents parents child;
  nn.topo <- Array.append nn.topo [|child|];
  child.network <- nn;
  (* if activation is specified, recursively add_node *)
  match act_typ with
  | Some act -> (
      let neuron = Activation (Activation.create act) in
      let child_of_child = make_node 0 [||] [||] neuron None nn in
      add_node nn [|child|] child_of_child
    )
  | None     -> child


(* functions to interface to optimisation engine *)

let init nn = Array.iter (fun n -> init n.neuron) nn.topo


let reset nn = Array.iter (fun n -> reset n.neuron) nn.topo


let mktag t nn = Array.iter (fun n -> mktag t n.neuron) nn.topo


let mkpar nn = Array.map (fun n -> mkpar n.neuron) nn.topo


let mkpri nn = Array.map (fun n -> mkpri n.neuron) nn.topo


let mkadj nn = Array.map (fun n -> mkadj n.neuron) nn.topo


let update nn us = Array.iter2 (fun n u -> update n.neuron u) nn.topo us


let run x nn =
  Array.iter (fun n ->
    (* collect the inputs from parents' output *)
    let input = match n.neuron with
      | Input _ -> [|x|]
      | _       -> collect_output n.prev
    in
    (* process the current neuron, save output *)
    let output = run_array input n.neuron in
    n.output <- Some output
  ) nn.topo;
  (* collect the final output from the tail *)
  let sink = [|nn.topo.(Array.length nn.topo - 1)|] in
  (collect_output sink).(0)


let forward nn x = mktag (tag ()) nn; run x nn, mkpar nn


let backward nn y = reverse_prop (F 1.) y; mkpri nn, mkadj nn


(* functions to create functional nodes *)


let input inputs =
  let neuron = Input (Input.create inputs) in
  let nn = make_network 1 None [||] in
  let n = make_node 0 [||] [||] neuron None nn in
  nn.root <- Some n;
  nn.topo <- [|n|];
  n


let activation act_typ input_node =
  let neuron = Activation (Activation.create act_typ) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node nn [|input_node|] n


let linear ?(init_typ = Init.Standard) ?act_typ outputs input_node =
  let neuron = Linear (Linear.create outputs init_typ) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node ?act_typ nn [|input_node|] n


let linear_nobias ?(init_typ = Init.Standard) ?act_typ outputs input_node =
  let neuron = LinearNoBias (LinearNoBias.create outputs init_typ) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node ?act_typ nn [|input_node|] n


let recurrent ?(init_typ=Init.Standard) ~act_typ outputs hiddens input_node =
  let neuron = Recurrent (Recurrent.create hiddens outputs act_typ init_typ) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node nn [|input_node|] n


let lstm cells input_node =
  let neuron = LSTM (LSTM.create cells) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node nn [|input_node|] n


let gru cells input_node =
  let neuron = GRU (GRU.create cells) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node nn [|input_node|] n


let conv2d ?(padding = Owl_dense_ndarray_generic.SAME) ?act_typ kernel strides input_node =
  let neuron = Conv2D (Conv2D.create padding kernel strides) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node ?act_typ nn [|input_node|] n


let conv3d ?(padding = Owl_dense_ndarray_generic.SAME) ?act_typ kernel_width kernel strides input_node =
  let neuron = Conv3D (Conv3D.create padding kernel strides) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node ?act_typ nn [|input_node|] n


let fully_connected ?(init_typ = Init.Standard) ?act_typ outputs input_node =
  let neuron = FullyConnected (FullyConnected.create outputs init_typ) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node ?act_typ nn [|input_node|] n


let max_pool2d ?(padding = Owl_dense_ndarray_generic.SAME) ?act_typ kernel stride input_node =
  let neuron = MaxPool2D (MaxPool2D.create padding kernel stride) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node ?act_typ nn [|input_node|] n


let avg_pool2d ?(padding = Owl_dense_ndarray_generic.SAME) ?act_typ kernel stride input_node =
  let neuron = AvgPool2D (AvgPool2D.create padding kernel stride) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node ?act_typ nn [|input_node|] n


let dropout rate input_node =
  let neuron = Dropout (Dropout.create rate) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node nn [|input_node|] n


let reshape ?convert outputs input_node=
  let neuron = Reshape (Reshape.create ?convert outputs) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node nn [|input_node|] n


let flatten ?convert input_node =
  let neuron = Flatten (Flatten.create ?convert ()) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node nn [|input_node|] n


let lambda ?act_typ lambda input_node =
  let neuron = Lambda (Lambda.create lambda) in
  let nn = get_network input_node in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node ?act_typ nn [|input_node|] n


let add ?act_typ input_node =
  let neuron = Add (Add.create ()) in
  let nn = get_network input_node.(0) in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node ?act_typ nn input_node n


let mul ?act_typ input_node =
  let neuron = Mul (Mul.create ()) in
  let nn = get_network input_node.(0) in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node ?act_typ nn input_node n


let max ?act_typ input_node =
  let neuron = Max (Max.create ()) in
  let nn = get_network input_node.(0) in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node ?act_typ nn input_node n


let average ?act_typ input_node =
  let neuron = Average (Average.create ()) in
  let nn = get_network input_node.(0) in
  let n = make_node 0 [||] [||] neuron None nn in
  add_node ?act_typ nn input_node n


(* training functions *)

let train ?params nn x y =
  Owl_neural_optimise.train_nn_generic
    ?params init forward backward update nn (Mat x) (Mat y)

let train_cnn ?params nn x y =
  Owl_neural_optimise.train_nn_generic
    ?params init forward backward update nn (Arr x) (Mat y)


(* I/O functions *)

let to_string nn =
  let s = ref "Graphical network\n\n" in
  Array.iter (fun n ->
    let t = to_string n.neuron in
    let prev = Array.map (fun n -> n.id) n.prev
      |> Owl_utils.string_of_array string_of_int
    in
    let next = Array.map (fun n -> n.id) n.next
      |> Owl_utils.string_of_array string_of_int
    in
    s := !s ^ (Printf.sprintf "(%i): %s" n.id t) ^
      (Printf.sprintf "    prev:[%s] next:[%s]\n\n" prev next)
  ) nn.topo; !s

let print nn = to_string nn |> Printf.printf "%s"

let save nn f = Owl_utils.marshal_to_file nn f

let load f : network = Owl_utils.marshal_from_file f



(* ends here *)
