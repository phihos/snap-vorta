#!/bin/sh

mkdir -p ~/.config/autostart

if [ "$SNAP_ARCH" = "amd64" ]; then
  ARCH="x86_64-linux-gnu"
elif [ "$SNAP_ARCH" = "armhf" ]; then
  ARCH="arm-linux-gnueabihf"
elif [ "$SNAP_ARCH" = "arm64" ]; then
  ARCH="aarch64-linux-gnu"
elif [ "$SNAP_ARCH" = "ppc64el" ]; then
  ARCH="powerpc64le-linux-gnu"
else
  ARCH="$SNAP_ARCH-linux-gnu"
fi
export SNAP_LAUNCHER_ARCH_TRIPLET=$ARCH

export PATH="$SNAP/bin:$SNAP/usr/bin:$PATH"

export GSETTINGS_SCHEMA_DIR=$SNAP/usr/share/glib-2.0/schemas
export GS_SCHEMA_DIR=$SNAP/usr/share/glib-2.0/schemas

export GTK_EXE_PREFIX="$SNAP/usr/lib/$SNAP_LAUNCHER_ARCH_TRIPLET"
export GDK_PIXBUF_MODULE_FILE="$GTK_EXE_PREFIX/gdk-pixbuf-2.0/2.10.0/loaders.cache"
export GIO_EXTRA_MODULES="$GTK_EXE_PREFIX/gio/modules"

# Disable opengl, or else we'll need to ship a bunch of mesa drivers and libegl
#export GSK_RENDERER=cairo

# Point at our internal python packages
export PYTHONHOME="$SNAP/usr"
#export PYTHONPATH="$SNAP/lib/python3.8/site-packages"

prepend_dir() {
  var="$1"
  dir="$2"
  if [ -d "$dir" ]; then
    eval "export $var=\"\$dir\${$var:+:\$$var}\""
  fi
}

append_dir() {
  var="$1"
  dir="$2"
  if [ -d "$dir" ]; then
    eval "export $var=\"\${$var:+\$$var:}\$dir\""
  fi
}

export RUNTIME=$SNAP
export USE_qt5=true
export wayland_available=false
# select qt version
. $SNAP/flavor-select

export QTCHOOSER_NO_GLOBAL_DIR=1
if [ "$USE_qt5" = true ]; then
  # QT_SELECT not exported by ubuntu app platform runtime
  if [ -z "$QT_SELECT" ]; then
    export QT_SELECT=snappy-qt5
  fi
else
  export QT_SELECT=snappy-qt4
fi

# Removes Qt warning: Could not find a location
# of the system Compose files
export QTCOMPOSE=$RUNTIME/usr/share/X11/locale

# Qt Libs, Modules and helpers
if [ "$USE_qt5" = true ]; then
  prepend_dir QT_PLUGIN_PATH $RUNTIME/usr/lib/$ARCH/qt5/plugins
  prepend_dir QML2_IMPORT_PATH $RUNTIME/usr/lib/$ARCH/qt5/qml
  prepend_dir QML2_IMPORT_PATH $RUNTIME/lib/$ARCH
  # Try to use qtubuntu-print plugin, if not found Qt will fallback to the first found (usually cups plugin)
  export QT_PRINTER_MODULE=qtubuntu-print
  if [ "$WITH_RUNTIME" = yes ]; then
    prepend_dir QML2_IMPORT_PATH $SNAP/usr/lib/$ARCH/qt5/qml
    prepend_dir QML2_IMPORT_PATH $SNAP/lib/$ARCH
  fi
  prepend_dir PATH $RUNTIME/usr/lib/$ARCH/qt5/bin

  if [ "$wayland_available" = true ]; then
    export QT_QPA_PLATFORM=wayland-egl
    # Does not hurt to specify these as well, just in case
    export GDK_BACKEND="wayland"
    export CLUTTER_BACKEND="wayland"
  else
    # Should check if a X11 $DISPLAY variable is set and accessible
    export QT_QPA_PLATFORM=xcb
  fi

else
  [ "$wayland_available" = true ] && echo "Warning: Qt4 does not support Wayland!"
  append_dir LD_LIBRARY_PATH $SNAP/usr/lib/$ARCH/qt4
  export QT_PLUGIN_PATH=$SNAP/usr/lib/$ARCH/qt4/plugins
  prepend_dir QML_IMPORT_PATH $SNAP/usr/lib/$ARCH/qt4/qml:$SNAP/lib/$ARCH
  prepend_dir PATH $SNAP/usr/lib/$ARCH/qt4/bin
fi

# Use GTK styling for running under the GNOME desktop
#append_dir GTK_PATH $RUNTIME/usr/lib/$ARCH/gtk-2.0

# Fix locating the QtWebEngineProcess executable
export QTWEBENGINEPROCESS_PATH=$RUNTIME/usr/lib/$ARCH/qt5/libexec/QtWebEngineProcess

export XDG_DATA_DIRS=$SNAP/usr/share:$SNAP/share






exec "${@}"
