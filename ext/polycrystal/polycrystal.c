#include <ruby.h>
#include <dlfcn.h>
#include "extconf.h"

static void (*__polycrystal_init)() = NULL;
static void (*__polycrystal_module_run)() = NULL;

static VALUE load_library(VALUE _self, VALUE path){
    char * cpath = StringValueCStr(path);
    void * handle = dlopen(cpath, RTLD_NOW|RTLD_LOCAL);
    if(handle != NULL){
        __polycrystal_init = (void (*)())dlsym(handle, "__polycrystal_init");
        if(__polycrystal_init != NULL){
            __polycrystal_init();
        }else{
            rb_raise(rb_eRuntimeError, "Load __polycrystal_init failed from %s: %s", cpath, dlerror());
            return Qnil;
        }
        __polycrystal_module_run = (void (*)())dlsym(handle, "__polycrystal_module_run");
        if(__polycrystal_module_run != NULL){
            __polycrystal_module_run();
        }else{
            rb_raise(rb_eRuntimeError, "Load __polycrystal_module_run failed from %s: %s", cpath, dlerror());
            return Qnil;
        }
    }else{
        rb_raise(rb_eRuntimeError, "Can't load library at %s: %s", cpath, dlerror());
        return Qnil;
    }
    return Qtrue;
}


void Init_polycrystal() {
    VALUE mod = rb_define_module("Polycrystal");
    VALUE class = rb_define_class_under(mod, "Loader", rb_cObject);
    rb_define_private_method(class, "load_library", load_library, 1);
}