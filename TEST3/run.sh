GL_PATH="../SRC/"
QUAT_PATH="../toolbox/quaternions/"
pushd $QUAT_PATH
make quaternions.cmo
popd
make vbo_draw.cmo ogl_matrix.cmo
ocaml -I $GL_PATH GL.cma Glut.cma bigarray.cma vertArray.cma VBO.cma \
      -I . vbo_draw.cmo ogl_matrix.cmo \
      -I $QUAT_PATH quaternions.cmo unix.cma $1
