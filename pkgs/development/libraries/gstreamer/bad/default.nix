{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  replaceVars,
  meson,
  ninja,
  gettext,
  pkg-config,
  python3,
  gst-plugins-base,
  orc,
  gstreamer,
  gobject-introspection,
  wayland-scanner,
  enableZbar ? false,
  faacSupport ? false,
  faac,
  opencvSupport ? false,
  opencv4,
  faad2,
  # Enabling lcevcdecoder currently causes issues when attempting to decode regular h264 data
  # warning: No decoder available for type 'video/x-h264, stream-format=(string)avc, [...], lcevc=(boolean)false, [...]
  lcevcdecSupport ? false,
  lcevcdec,
  ldacbtSupport ? lib.meta.availableOn stdenv.hostPlatform ldacbt,
  ldacbt,
  liblc3,
  libass,
  lrdf,
  ladspaH,
  lcms2,
  libnice,
  webrtcAudioProcessingSupport ? lib.meta.availableOn stdenv.hostPlatform webrtc-audio-processing_1,
  webrtc-audio-processing_1,
  lilv,
  lv2,
  serd,
  sord,
  sratom,
  libbs2b,
  libmodplug,
  libmpeg2,
  libmicrodns,
  openjpeg,
  libopus,
  librsvg,
  bluez,
  chromaprint,
  curl,
  fdk_aac,
  flite,
  gsm,
  json-glib,
  ajaSupport ? lib.meta.availableOn stdenv.hostPlatform libajantv2,
  libajantv2,
  libaom,
  libdc1394,
  libde265,
  libdrm,
  libdvdnav,
  libdvdread,
  libgudev,
  qrencode,
  libsndfile,
  libusb1,
  neon,
  openal,
  openexr,
  openh264Support ? lib.meta.availableOn stdenv.hostPlatform openh264,
  openh264,
  libopenmpt,
  pango,
  rtmpdump,
  sbc,
  soundtouch,
  spandsp,
  srtp,
  zbar,
  wayland-protocols,
  wildmidi,
  svt-av1,
  fluidsynth,
  libva,
  wayland,
  libwebp,
  gnutls,
  mjpegtools,
  libGL,
  addDriverRunpath,
  gtk3,
  libintl,
  game-music-emu,
  openssl,
  x265,
  libxml2,
  srt,
  vo-aacenc,
  libfreeaptx,
  zxing-cpp,
  usrsctp,
  directoryListingUpdater,
  enableGplPlugins ? true,
  bluezSupport ? stdenv.hostPlatform.isLinux,
  # Causes every application using GstDeviceMonitor to send mDNS queries every 2 seconds
  microdnsSupport ? false,
  # Checks meson.is_cross_build(), so even canExecute isn't enough.
  enableDocumentation ? stdenv.hostPlatform == stdenv.buildPlatform,
  hotdoc,
  guiSupport ? true,
  gst-plugins-bad,
  apple-sdk_gstreamer,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gst-plugins-bad";
  version = "1.26.0";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchurl {
    url = "https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-${finalAttrs.version}.tar.xz";
    hash = "sha256-+Ch6hMX2Y2ilpQ2l+WmZSgLEfyAiD/4coxVBk+Za8hY=";
  };

  patches = [
    # Add fallback paths for nvidia userspace libraries
    (replaceVars ./fix-paths.patch {
      inherit (addDriverRunpath) driverLink;
    })

    # Fix Requires in gstreamer-analytics-1.0.pc
    # https://gitlab.freedesktop.org/gstreamer/gstreamer/-/merge_requests/8661
    (fetchpatch {
      url = "https://gitlab.freedesktop.org/gstreamer/gstreamer/-/commit/bc93bbf5c87ec994ea136bb40accc09dfa35ae98.patch";
      stripLen = 2;
      hash = "sha256-QQDpHe363iPxTuthITRbLUKaAXS2F9s5zfCn/ps14WE=";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    orc # for orcc
    python3
    gettext
    gstreamer # for gst-tester-1.0
    gobject-introspection
  ]
  ++ lib.optionals enableDocumentation [
    hotdoc
  ]
  ++ lib.optionals (gst-plugins-base.waylandEnabled && stdenv.hostPlatform.isLinux) [
    wayland-scanner
  ];

  buildInputs = [
    gst-plugins-base
    orc
    json-glib
    lcms2
    liblc3
    libass
    libbs2b
    libmodplug
    openjpeg
    libopenmpt
    libopus
    librsvg
    curl.dev
    fdk_aac
    gsm
    libaom
    libdc1394
    libde265
    libdvdnav
    libdvdread
    libnice
    qrencode
    libsndfile
    libusb1
    neon
    openal
    openexr
    rtmpdump
    pango
    soundtouch
    srtp
    fluidsynth
    libwebp
    gnutls
    game-music-emu
    openssl
    libxml2
    libintl
    srt
    vo-aacenc
    libfreeaptx
    zxing-cpp
    usrsctp
    wildmidi
    svt-av1
  ]
  ++ lib.optionals opencvSupport [
    opencv4
  ]
  ++ lib.optionals enableZbar [
    zbar
  ]
  ++ lib.optionals faacSupport [
    faac
  ]
  ++ lib.optionals enableGplPlugins [
    libmpeg2
    mjpegtools
    faad2
    x265
  ]
  ++ lib.optionals bluezSupport [
    bluez
  ]
  ++ lib.optionals microdnsSupport [
    libmicrodns
  ]
  ++ lib.optionals openh264Support [
    openh264
  ]
  ++ lib.optionals ajaSupport [
    libajantv2
  ]
  ++ lib.optionals (gst-plugins-base.waylandEnabled && stdenv.hostPlatform.isLinux) [
    libva # vaapi requires libva -> libdrm -> libpciaccess, which is Linux-only in nixpkgs
    wayland
    wayland-protocols
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    # TODO: mjpegtools uint64_t is not compatible with guint64 on Darwin
    mjpegtools

    chromaprint
    flite
    libdrm
    libgudev
    sbc
    spandsp

    # ladspa plug-in
    ladspaH
    lrdf # TODO: make build on Darwin

    # lv2 plug-in
    lilv
    lv2
    serd
    sord
    sratom

    libGL
  ]
  ++ lib.optionals guiSupport [
    gtk3
  ]
  ++ lib.optionals lcevcdecSupport [
    lcevcdec
  ]
  ++ lib.optionals ldacbtSupport [
    ldacbt
  ]
  ++ lib.optionals webrtcAudioProcessingSupport [
    webrtc-audio-processing_1
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_gstreamer
  ];

  mesonFlags = [
    "-Dexamples=disabled" # requires many dependencies and probably not useful for our users
    "-Dglib_debug=disabled" # cast checks should be disabled on stable releases

    "-Damfcodec=disabled" # Windows-only
    "-Dandroidmedia=disabled" # Requires Android system.
    "-Davtp=disabled"
    "-Dcuda-nvmm=disabled"
    "-Ddirectshow=disabled" # Windows-only
    "-Dqt6d3d11=disabled" # Windows-only
    "-Ddts=disabled" # required `libdca` library not packaged in nixpkgs as of writing, and marked as "BIG FAT WARNING: libdca is still in early development"
    "-Dzbar=${if enableZbar then "enabled" else "disabled"}"
    "-Dfaac=${if faacSupport then "enabled" else "disabled"}"
    "-Diqa=disabled" # required `dssim` library not packaging in nixpkgs as of writing, also this is AGPL so update license when adding support
    "-Dlcevcencoder=disabled" # not packaged in nixpkgs as of writing
    "-Dmagicleap=disabled" # required `ml_audio` library not packaged in nixpkgs as of writing
    "-Dmsdk=disabled" # not packaged in nixpkgs as of writing / no Windows support
    # As of writing, with `libmpcdec` in `buildInputs` we get
    #   "Could not find libmpcdec header files, but Musepack was enabled via options"
    # This is likely because nixpkgs has the header in libmpc/mpcdec.h
    # instead of mpc/mpcdec.h, like Arch does. The situation is not trivial.
    # There are apparently 2 things called `libmpcdec` from the same author:
    #   * http://svn.musepack.net/libmpcdec/trunk/src/
    #   * http://svn.musepack.net/libmpc/trunk/include/mpc/
    # Fixing it likely requires to first figure out with upstream which one
    # is needed, and then patching upstream to find it (though it probably
    # already works on Arch?).
    "-Dmusepack=disabled"
    "-Dnvcomp=disabled"
    "-Dnvdswrapper=disabled"
    "-Dopenni2=disabled" # not packaged in nixpkgs as of writing
    "-Dopensles=disabled" # not packaged in nixpkgs as of writing
    "-Dsvthevcenc=disabled" # required `SvtHevcEnc` library not packaged in nixpkgs as of writing
    "-Dsvtjpegxs=disabled" # not packaged in nixpkgs as of writing
    "-Dteletext=disabled" # required `zvbi` library not packaged in nixpkgs as of writing
    "-Dtinyalsa=disabled" # not packaged in nixpkgs as of writing
    "-Dvoamrwbenc=disabled" # required `vo-amrwbenc` library not packaged in nixpkgs as of writing
    "-Dvulkan=disabled" # Linux-only, and we haven't figured out yet which of the vulkan nixpkgs it needs
    "-Dwasapi=disabled" # not packaged in nixpkgs as of writing / no Windows support
    "-Dwasapi2=disabled" # not packaged in nixpkgs as of writing / no Windows support
    "-Dwpe=disabled" # required `wpe-webkit` library not packaged in nixpkgs as of writing
    "-Dgs=disabled" # depends on `google-cloud-cpp`
    "-Donnx=disabled" # depends on `libonnxruntime` not packaged in nixpkgs as of writing
    "-Dopenaptx=enabled" # since gstreamer-1.20.1 `libfreeaptx` is supported for circumventing the dubious license conflict with `libopenaptx`
    "-Dopencv=${if opencvSupport then "enabled" else "disabled"}" # Reduces rebuild size when `config.cudaSupport = true`
    "-Daja=${if ajaSupport then "enabled" else "disabled"}"
    "-Dmicrodns=${if microdnsSupport then "enabled" else "disabled"}"
    "-Dbluez=${if bluezSupport then "enabled" else "disabled"}"
    (lib.mesonEnable "openh264" openh264Support)
    (lib.mesonEnable "doc" enableDocumentation)
    (lib.mesonEnable "directfb" false)
    (lib.mesonEnable "lcevcdecoder" lcevcdecSupport)
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isLinux) [
    "-Ddoc=disabled" # needs gstcuda to be enabled which is Linux-only
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isLinux || !stdenv.hostPlatform.isx86) [
    "-Dnvcodec=disabled" # Linux-only, broken on non-x86
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isLinux || !gst-plugins-base.waylandEnabled) [
    "-Dva=disabled" # see comment on `libva` in `buildInputs`
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "-Daja=disabled"
    "-Dchromaprint=disabled"
    "-Dflite=disabled"
    "-Dkms=disabled" # renders to libdrm output
    "-Dlv2=disabled"
    "-Dsbc=disabled"
    "-Dspandsp=disabled"
    "-Ddvb=disabled"
    "-Dfbdev=disabled"
    "-Duvcgadget=disabled" # requires gudev
    "-Duvch264=disabled" # requires gudev
    "-Dv4l2codecs=disabled" # requires gudev
    "-Dladspa=disabled" # requires lrdf
  ]
  ++
    lib.optionals
      (!stdenv.hostPlatform.isLinux || !stdenv.hostPlatform.isx86_64 || !gst-plugins-base.waylandEnabled)
      [
        "-Dqsv=disabled" # Linux (and Windows) x86 only, makes va required
      ]
  ++ lib.optionals (!gst-plugins-base.glEnabled) [
    "-Dgl=disabled"
  ]
  ++ lib.optionals (!gst-plugins-base.waylandEnabled || !guiSupport) [
    "-Dgtk3=disabled" # Wayland-based GTK sink
    "-Dwayland=disabled"
  ]
  ++ lib.optionals (!gst-plugins-base.glEnabled) [
    # `applemedia/videotexturecache.h` requires `gst/gl/gl.h`,
    # but its meson build system does not declare the dependency.
    "-Dapplemedia=disabled"
  ]
  ++ (
    if enableGplPlugins then
      [
        "-Dgpl=enabled"
      ]
    else
      [
        "-Ddts=disabled"
        "-Dfaad=disabled"
        "-Diqa=disabled"
        "-Dmpeg2enc=disabled"
        "-Dmplex=disabled"
        "-Dresindvd=disabled"
        "-Dx265=disabled"
      ]
  );

  # Argument list too long
  strictDeps = true;

  postPatch = ''
    patchShebangs \
      scripts/extract-release-date-from-doap-file.py
  '';

  # This package has some `_("string literal")` string formats
  # that trip up clang with format security enabled.
  hardeningDisable = [ "format" ];

  doCheck = false; # fails 20 out of 58 tests, expensive

  passthru = {
    tests = {
      full = gst-plugins-bad.override {
        enableZbar = true;
        faacSupport = true;
        opencvSupport = true;
      };

      lgplOnly = gst-plugins-bad.override {
        enableGplPlugins = false;
      };
    };

    updateScript = directoryListingUpdater { };
  };

  meta = with lib; {
    description = "GStreamer Bad Plugins";
    mainProgram = "gst-transcoder-1.0";
    homepage = "https://gstreamer.freedesktop.org";
    longDescription = ''
      a set of plug-ins that aren't up to par compared to the
      rest.  They might be close to being good quality, but they're missing
      something - be it a good code review, some documentation, a set of tests,
      a real live maintainer, or some actual wide use.
    '';
    license = if enableGplPlugins then licenses.gpl2Plus else licenses.lgpl2Plus;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers; [ matthewbauer ];
  };
})
