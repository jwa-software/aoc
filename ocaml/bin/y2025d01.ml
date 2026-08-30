(* Advent of Code 2025 day 1, part one. Part two is not written here: its text is
   not visible until part one has been accepted. *)

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

(* The dial has 100 positions and every rotation wraps, so a position is an
   integer modulo 100. OCaml's `mod` takes the sign of its left operand, so
   turning left past 0 leaves a negative remainder - (-999) mod 100 is -99, not
   1 - and the value has to be pushed back into range. A single addition is
   enough, because `mod` has already brought it inside (-100, 100). *)
let wrap n = ((n mod 100) + 100) mod 100

(* A rotation is a direction character followed by a distance. Returning a
   signed offset lets the fold add unconditionally instead of branching on the
   direction a second time. *)
let offset line =
  let distance =
    match int_of_string_opt (String.sub line 1 (String.length line - 1)) with
    | Some distance -> distance
    | None -> Printf.ksprintf failwith "unparseable rotation distance in %S" line
  in
  match line.[0] with
  | 'L' -> -distance
  | 'R' -> distance
  | c -> Printf.ksprintf failwith "unknown rotation direction %C in %S" c line
;;

(* The answer is not where the dial ends up but how many rotations ended on 0, so
   only each rotation's endpoint is examined. Passing over 0 partway through a
   rotation does not count, which is why the distance never has to be walked one
   click at a time. *)
let password rotations =
  let step (position, count) line =
    let position = wrap (position + offset line) in
    position, if position = 0 then count + 1 else count
  in
  let _, count = List.fold_left step (50, 0) rotations in
  count
;;

let () =
  let rotations =
    read_lines (input_path ())
    (* A file ending in a newline yields no empty line here, but a stray blank
       one would otherwise surface as an index error naming nothing. *)
    |> List.filter (fun line -> not (String.equal line ""))
  in
  Printf.printf "part one: %d\n" (password rotations)
;;
