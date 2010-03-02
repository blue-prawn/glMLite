(* Using VBO's with OpenGL 3.X *)
(* The code of this file was converted and adapted from C to ocaml
   from a tutorial by Michael Gallego, which is there :
   http://bakura.developpez.com/tutoriels/jeux/utilisation-vbo-avec-opengl-3-x/
   You can reuse this code (with Vbo_draw and Ogl_matrix) without restrictions.
*)

open GL
open Glut
open Vbo_draw
open Ogl_matrix

(* product of the modelview (world) matrix and the projection matrix *)
let worldViewProjectionMatrix = ref [| |]

let cubeArray =
  RGB_Vertices3 [|
    (* RGB colors *) (* XYZ coords *)
    (0.0, 1.0, 0.0), (-1.0,  1.0, -1.0);
    (0.0, 0.0, 0.0), (-1.0, -1.0, -1.0);
    (1.0, 1.0, 0.0), (-1.0,  1.0,  1.0);
    (1.0, 0.0, 0.0), (-1.0, -1.0,  1.0);
    (1.0, 1.0, 1.0), ( 1.0,  1.0,  1.0);
    (1.0, 0.0, 1.0), ( 1.0, -1.0,  1.0);
    (0.0, 1.0, 1.0), ( 1.0,  1.0, -1.0);
    (0.0, 0.0, 1.0), ( 1.0, -1.0, -1.0);
  |]

let indiceArray =
  (* quad faces *)
  [| (0,1,3,2);
     (4,5,7,6);
     (3,1,7,5);
     (0,2,4,6);
     (6,7,1,0);
     (2,3,5,4); |]


let reshape ~width ~height =
  let height = max height 1 in
  glViewport 0 0 width height;
  let ratio = float width /. float height in

  (* creation of the matrices *)
  let projectionMatrix = projection_matrix 60.0 ratio 1.0 500.0 in
  let worldMatrix = transformation_matrix (0.0, 0.0, -6.0) in
  worldViewProjectionMatrix := mult_matrix4 projectionMatrix worldMatrix;
;;


let init_OpenGL ~width ~height =
  reshape ~width ~height;

  glEnable GL_DEPTH_TEST;
;;

let frame_count = ref 0

let display mesh_with_shaders = function () ->
  glClear [GL_COLOR_BUFFER_BIT; GL_DEPTH_BUFFER_BIT];

  let now = Unix.gettimeofday() in
  let x = cos now
  and y = sin now in

  let rotation = Quaternions.quaternion_of_axis (0.0, x, y) (now *. 0.8) in
  let m = Quaternions.matrix_of_quaternion rotation in
  let my_mat = mult_matrix4 !worldViewProjectionMatrix m in

  draw_mesh my_mat mesh_with_shaders;

  incr frame_count;
  glutSwapBuffers();
;;

let last_time = ref(Unix.gettimeofday())

(* main *)
let () =
  let width = 800 and height = 600 in
  ignore(glutInit Sys.argv);
  glutInitDisplayMode [GLUT_RGB; GLUT_DOUBLE; GLUT_DEPTH];
  glutInitWindowPosition ~x:100 ~y:100;
  glutInitWindowSize ~width ~height;
  ignore(glutCreateWindow ~title:"VBO with OpenGL 3.X");

  init_OpenGL ~width ~height;

  (* make a mesh ready to be drawn *)
  let mesh_with_shaders = make_mesh (tris_of_quads indiceArray) cubeArray in

  glutDisplayFunc ~display:(display mesh_with_shaders);

  glutKeyboardFunc ~keyboard:(fun ~key ~x ~y ->
      if key = '\027' then (delete_mesh mesh_with_shaders; exit 0));
  glutIdleFunc ~idle:glutPostRedisplay;
  let msecs = 5000 in  (* every 5 seconds *)
  let rec timer ~value:msecs =
    glutTimerFunc ~msecs ~timer ~value:msecs;
    let now = Unix.gettimeofday() in
    let diff = (now -. !last_time) in
    Printf.printf " %d frames in %f seconds \t fps: %g\n%!"
                  !frame_count diff (float !frame_count /. diff);
    frame_count := 0;
    last_time := now;
  in
  glutTimerFunc ~msecs ~timer ~value:msecs;

  glutMainLoop();
;;
