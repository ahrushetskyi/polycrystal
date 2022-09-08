#include <ruby.h>

extern void* open_interpreter(void) {

  return (void*) 0;

}

extern void close_interpreter(void* rb) {


}

extern void load_script_from_file(void* rb, const char* filename) {



}

extern VALUE execute_script_line(void* rb, const char* text) {

  int status;
  VALUE result = rb_eval_string_protect(text, &status);

  if(status) {

    VALUE exception = rb_errinfo();
    VALUE exception_str = rb_inspect(exception);

    //! TODO: Are there any internal methods to print this prettier?

    printf("%s\n", rb_string_value_cstr(&exception_str));

  }

  return result;

}