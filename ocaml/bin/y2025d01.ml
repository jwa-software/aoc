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

(* The direction is kept rather than folded into the sign of the distance,
   because where the first zero-click of a rotation falls is not symmetric
   between the two directions and the second count needs to know which way the
   dial turned. *)
type direction =
  | Left
  | Right

let parse line =
  let distance =
    match int_of_string_opt (String.sub line 1 (String.length line - 1)) with
    | Some distance -> distance
    | None -> Printf.ksprintf failwith "unparseable rotation distance in %S" line
  in
  match line.[0] with
  | 'L' -> Left, distance
  | 'R' -> Right, distance
  | c -> Printf.ksprintf failwith "unknown rotation direction %C in %S" c line
;;

let offset (direction, distance) =
  match direction with
  | Left -> -distance
  | Right -> distance
;;

(* Within one rotation the clicks that land on 0 are evenly spaced: the first
   after `first` clicks, then one every 100 after that. `first` is the distance
   to 0 in the direction of travel, and is 100 rather than 0 when the dial
   already points at 0, because a click has to move the dial before it can
   arrive. Counting them closed-form rather than walking the rotation keeps the
   rule visible and makes a distance of 1000 cost the same as one of 5. *)
let clicks_at_zero (direction, distance) position =
  let first =
    match direction with
    | Right -> 100 - position
    | Left -> if position = 0 then 100 else position
  in
  if distance < first then 0 else ((distance - first) / 100) + 1
;;

(* The first count takes only the rotations that ended on 0; the second takes
   every click that lands on 0, which subsumes those endpoints rather than being
   added to them. Both walk the same positions, so one pass carries both. The
   clicks of a rotation are counted from the position it started at, which is
   why that count is taken before the position moves. *)
let passwords rotations =
  let step (position, ends, clicks) line =
    let rotation = parse line in
    let clicks = clicks + clicks_at_zero rotation position in
    let position = wrap (position + offset rotation) in
    position, (if position = 0 then ends + 1 else ends), clicks
  in
  let _, ends, clicks = List.fold_left step (50, 0, 0) rotations in
  ends, clicks
;;

let () =
  let rotations =
    read_lines (input_path ())
    (* A file ending in a newline yields no empty line here, but a stray blank
       one would otherwise surface as an index error naming nothing. *)
    |> List.filter (fun line -> not (String.equal line ""))
  in
  let ends, clicks = passwords rotations in
  Printf.printf "part one: %d\n" ends;
  Printf.printf "part two: %d\n" clicks
;;
