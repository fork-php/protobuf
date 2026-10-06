PHP_ARG_ENABLE(protobuf, whether to enable Protobuf extension, [  --enable-protobuf   Enable Protobuf extension])

if test "$PHP_PROTOBUF" != "no"; then

  dnl Zend headers require C11 as of PHP 8.7
  if test `$PHP_CONFIG --vernum` -ge 80700; then
    PHP_PROTOBUF_STD=-std=gnu11
  else
    PHP_PROTOBUF_STD=-std=gnu99
  fi

  PHP_NEW_EXTENSION(
    protobuf,
    arena.c array.c convert.c def.c map.c message.c names.c print_options.c php-upb.c protobuf.c third_party/utf8_range/utf8_range.c,
    $ext_shared, , $PHP_PROTOBUF_STD -I@ext_srcdir@/third_party/utf8_range)
  PHP_ADD_BUILD_DIR($ext_builddir/third_party/utf8_range)

fi
