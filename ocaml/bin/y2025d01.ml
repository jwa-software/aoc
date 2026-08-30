(* Scaffolding only: locating and reading the input. Neither part of the puzzle
   is solved here yet. *)

(* The executable's own name is the day token, so the input path is derived
   rather than passed in. Tying the two names together means a solution cannot
   be run against another day's input by mistake, and it is why the token is one
   word rather than a year directory plus a day file. *)
let token = Filename.remove_extension (Filename.basename Sys.executable_name)

(* `dune exec` runs the executable with the working directory the caller was in,
   and the executable itself lives several levels down inside _build, so no
   fixed relative path reaches the repository root from both. Walking up until a
   data/ directory appears makes the lookup independent of where it was invoked
   from. *)
let rec find_root dir =
  if Sys.file_exists (Filename.concat dir "data")
  then Some dir
  else (
    let parent = Filename.dirname dir in
    (* Filename.dirname of a filesystem root returns that root unchanged, which
       is the only stopping condition available without asking the OS. *)
    if String.equal parent dir then None else find_root parent)
;;

let input_path () =
  match find_root (Sys.getcwd ()) with
  | Some root -> Filename.concat (Filename.concat root "data") (token ^ ".txt")
  | None ->
    (* Inputs are not committed, so this is the expected first failure on a fresh
       checkout rather than a broken build. *)
    failwith "no data/ directory found at or above the working directory"
;;

let read_lines path =
  let ic = open_in path in
  Fun.protect
    ~finally:(fun () -> close_in ic)
    (fun () ->
       let rec loop acc =
         match input_line ic with
         | line -> loop (line :: acc)
         | exception End_of_file -> List.rev acc
       in
       loop [])
;;

let () =
  let lines = read_lines (input_path ()) in
  Printf.printf "read %d lines\n" (List.length lines)
;;
