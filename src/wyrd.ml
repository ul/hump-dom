type vNode
type document
type window
type timer
type animationFrame
type element

type propObj

type infernoChildren =
  | Text of string
  | V of (vNode array)

type styleProperty =
  | BackgroundColor of string
  | Color of string

type 'a htmlProperty =
  | Style of (styleProperty list)
  | OnClick of (unit -> unit)

external dom : document = "document" [@@bs.val]
external win : window = "window" [@@bs.val]

external getElementById : document -> string -> element = "" [@@bs.send]
external setTimeout : window -> (unit -> unit [@bs]) -> float -> timer = "" [@@bs.send]
external requestAnimationFrame : window -> (unit -> unit [@bs]) -> animationFrame = "" [@@bs.send]

external render : vNode -> element -> unit = "" [@@bs.module "inferno"]

external hyperscript : string -> < .. > Js.t -> infernoChildren -> vNode = "default" [@@bs.module "inferno-hyperscript", "H"]

external makeObj : unit -> < .. > Js.t = "" [@@bs.obj]

let styleHandler prop obj =
  match prop with
  | BackgroundColor color -> obj##backgroundColor #= color; obj
  | Color color -> obj##color #= color; obj

let handleProperties handler props =
  List.fold_right handler props (makeObj ())

let htmlHandler prop obj =
  match prop with
  | Style styles -> obj##style #= (handleProperties styleHandler styles); obj
  | OnClick func -> obj##onClick #= func; obj

let h_ a c = hyperscript a (makeObj ()) c

let h tag props children = hyperscript tag (handleProperties htmlHandler props) children

let startApp containerId view update model =
  let actions = ref [] in
  let queueAction action () =
     actions := action :: !actions; in
  let container = getElementById dom containerId in
  let _ = render (view model queueAction) container in
  let rec loop model =
    let model = match !actions with
                              | [] -> model
                              | actionList -> let model = List.fold_right update actionList model in
                                              render (view model queueAction) container;
                                                actions := [];
                                                model
    in
    ignore @@ requestAnimationFrame win (fun () -> loop model; [@bs]);
  in
  loop model
