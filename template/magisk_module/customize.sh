# shellcheck disable=SC2034
SKIPUNZIP=1

FLAVOR=zygisk

enforce_install_from_magisk_app() {
  if $BOOTMODE; then
    ui_print "- Installing from Magisk app"
  else
    ui_print "*********************************************************"
    ui_print "! Install from recovery is NOT supported"
    ui_print "! Recovery sucks"
    ui_print "! Please install from Magisk app"
    abort "*********************************************************"
  fi
}

check_magisk_version() {
  ui_print "- Magisk version: $MAGISK_VER_CODE"
  if [ "$MAGISK_VER_CODE" -lt 24000 ]; then
    ui_print "*********************************************************"
    ui_print "! Please install Magisk v24.0+ (24000+)"
    abort    "*********************************************************"
  fi
}

VERSION=$(grep_prop version "${TMPDIR}/module.prop")
ui_print "- myMagiskFrida version ${VERSION}"

# Extract verify.sh
ui_print "- Extracting verify.sh"
unzip -o "$ZIPFILE" 'verify.sh' -d "$TMPDIR" >&2
if [ ! -f "$TMPDIR/verify.sh" ]; then
  ui_print "*********************************************************"
  ui_print "! Unable to extract verify.sh!"
  ui_print "! This zip may be corrupted, please try downloading again"
  abort    "*********************************************************"
fi
. "$TMPDIR/verify.sh"

extract "$ZIPFILE" 'customize.sh' "$TMPDIR"
extract "$ZIPFILE" 'verify.sh' "$TMPDIR"

check_magisk_version
enforce_install_from_magisk_app

# Check architecture
if [ "$ARCH" != "arm" ] && [ "$ARCH" != "arm64" ] && [ "$ARCH" != "x86" ] && [ "$ARCH" != "x64" ]; then
  abort "! Unsupported platform: $ARCH"
else
  ui_print "- Device platform: $ARCH"
fi

if [ "$API" -lt 27 ]; then
  abort "! Only support SDK 27+ devices"
fi

extract "$ZIPFILE" 'module.prop'        "$MODPATH"
extract "$ZIPFILE" 'service.sh'         "$MODPATH"
extract "$ZIPFILE" 'uninstall.sh'       "$MODPATH"

ui_print "- Extracting zygisk libraries"

if [ "$FLAVOR" == "zygisk" ]; then

  ui_print "- unzip arm64-v8a.so"
  mkdir -p "$MODPATH/zygisk"
  if [ "$ARCH" = "arm" ] || [ "$ARCH" = "arm64" ]; then
    extract "$ZIPFILE" "zygisk/armeabi-v7a.so" "$MODPATH/zygisk" true

    if [ "$IS64BIT" = true ]; then
      extract "$ZIPFILE" "zygisk/arm64-v8a.so" "$MODPATH/zygisk" true
    fi
  fi

  #ui_print "- unzip dex"
  #F_DEXDIR="$MODPATH/system/framework"
  #mkdir -p "$F_DEXDIR"
  #extract "$ZIPFILE" "system/framework/module.dex" "$F_DEXDIR" true

  ui_print "- copy my frida"
  F_TARGETDIR="$MODPATH/system/bin"
  mkdir -p "$F_TARGETDIR"
  extract "$ZIPFILE" "files/frida-server-$ARCH" "$F_TARGETDIR" true
  mv "$F_TARGETDIR/frida-server-$ARCH" "$F_TARGETDIR/fs16-4-7"
  ui_print "- copy my $F_TARGETDIR/fs16-4-7 ok"
fi


set_perm_recursive "$MODPATH" 0 0 0755 0644

set_perm $MODPATH/system/bin/fs16-4-7 0 2000 0755 u:object_r:system_file:s0
#set_perm $MODPATH/system/framework/module.dex 0 2000 0755 u:object_r:system_file:s0

ui_print "嘿嘿嘿，安装成功!!!"
