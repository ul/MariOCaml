open Actors
open Sprite
open Object
module Html = Dom_html
module Pg = Procedural_generator

let loadCount =  ref 0
let imgsToLoad = 4
let level_width = 2400.
let level_height = 256.

(*Canvas is chosen from the index.html file. The context is obtained from
 *the canvas. Listeners are added. A level is generated and the general
 *update_loop method is called to make the level playable.*)
let load _ =
  Random.self_init();
  let canvas_id = "canvas" in
  let canvas =
    Js.Opt.get
      (Js.Opt.bind ( Html.document##getElementById(canvas_id))
        Html.CoerceTo.canvas)
      (fun () ->
        Printf.printf "cant find canvas %s \n" canvas_id;
        failwith "fail"
      ) in
  let context = canvas##getContext (Html._2d_) in
  let _ = Html.addEventListener Html.document Html.Event.keydown (Html.handler Director.keydown) Js.true_ in
  let _ = Html.addEventListener Html.document Html.Event.keyup (Html.handler Director.keyup) Js.true_ in
  let () = Pg.init () in
  let _ = Director.update_loop canvas (Pg.generate level_width level_height context) (level_width,level_height) in
  print_endline "asd";
  ()

let inc_counter _ =
  loadCount := !loadCount + 1;
  if !loadCount = imgsToLoad then load() else ()

(*Used for concurrency issues.*)
let preload _ =
  let root_dir = "sprites/" in
  let imgs = [ "blocks.png";"items.png";"enemies.png";"mario-small.png" ] in
  List.map (fun img_src ->
    let img_src = root_dir ^ img_src in
    let img = (Html.createImg Html.document) in
    img##src #= (img_src) ;
    ignore(Html.addEventListener  img Html.Event.load
    (Html.handler (fun ev ->  inc_counter(); Js.true_)) Js.true_)) imgs


let _ = Html.window##onload #= Html.handler (fun _ -> ignore (preload()); Js.true_)
