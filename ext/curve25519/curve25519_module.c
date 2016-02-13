#include "ruby.h"

VALUE curve25519_module = Qnil;

int curve25519_donna(uint8_t *mypublic, const uint8_t *secret, const uint8_t *basepoint);

VALUE method_mult(VALUE klass, VALUE a, VALUE b)
{
  uint8_t buffer[32];
  if (TYPE(a) != T_STRING || RSTRING_LEN(a) != 32 ||
      TYPE(b) != T_STRING || RSTRING_LEN(b) != 32)
  {
    rb_raise(rb_eArgError, "Both arguments must be 32 byte strings");
  }
  curve25519_donna(buffer, (uint8_t*)RSTRING_PTR(a), (uint8_t*)RSTRING_PTR(b));
  return rb_str_new((char*)buffer, 32);
}

void Init_curve25519()
{
  VALUE ephemeral_calc_module = rb_const_get(rb_cObject, rb_intern("EphemeralCalc"));
  curve25519_module = rb_define_module_under(ephemeral_calc_module, "Curve25519");
  rb_define_singleton_method(curve25519_module, "mult", method_mult, 2);
  uint8_t basepoint[32] = {9};
  rb_define_const(curve25519_module, "BASEPOINT", rb_str_new( (char*)basepoint, 32) );
}
