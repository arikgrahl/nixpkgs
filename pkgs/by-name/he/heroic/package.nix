{
  buildFHSEnv,
  heroic-unwrapped,
  extraPkgs ? pkgs: [ ],
  extraLibraries ? pkgs: [ ],
}:

buildFHSEnv {
  pname = "heroic";
  inherit (heroic-unwrapped) version;

  runScript = "heroic";

  # Many Wine and native games need 32-bit libraries.
  multiArch = true;

  # required by Electron
  unshareIpc = false;

  targetPkgs =
    pkgs:
    with pkgs;
    [
      heroic-unwrapped
      gamemode
      curl
      gawk
      zenity
      kdePackages.kdialog
      mangohud
      net-tools
      opencl-headers
      p7zip
      pciutils
      perl
      psmisc
      python3
      umu-launcher
      unzip
      which
      xorg.xrandr
      zstd
    ]
    ++ extraPkgs pkgs;

  multiPkgs =
    let
      xorgDeps =
        pkgs: with pkgs.xorg; [
          libICE
          libpthreadstubs
          libSM
          libX11
          libXaw
          libxcb
          libXcomposite
          libXcursor
          libXdmcp
          libXext
          libXfixes
          libXi
          libXinerama
          libXmu
          libXrandr
          libXrender
          libXScrnSaver
          libXt
          libXtst
          libXv
          libXxf86vm
        ];
      gstreamerDeps =
        pkgs: with pkgs.gst_all_1; [
          gstreamer
          gst-plugins-base
          gst-plugins-good
          gst-plugins-ugly
          gst-plugins-bad
          gst-libav
        ];
    in
    pkgs:
    with pkgs;
    [
      alsa-lib
      alsa-plugins
      bash
      cabextract
      cairo
      coreutils
      cups
      dbus
      freealut
      freetype
      fribidi
      giflib
      glib
      gnutls
      gtk3
      icu
      lcms2
      libevdev
      libgcrypt
      libGLU
      libglvnd
      libgpg-error
      libgudev
      libjpeg
      libkrb5
      libmpeg2
      libogg
      libopus
      libpng
      libpulseaudio
      libselinux
      libsndfile
      libtheora
      libtiff
      libunwind
      libusb1
      libv4l
      libva
      libvdpau
      libvorbis
      libvpx
      libwebp
      libxkbcommon
      libxml2
      mpg123
      ncurses
      ocl-icd
      openal
      openldap
      openssl
      pango
      pipewire
      samba4
      sane-backends
      SDL2
      speex
      sqlite
      udev
      unixODBC
      util-linux
      vulkan-loader
      wayland
      zlib
    ]
    ++ xorgDeps pkgs
    ++ gstreamerDeps pkgs
    ++ extraLibraries pkgs;

  extraInstallCommands = ''
    mkdir -p $out/share
    ln -s ${heroic-unwrapped}/share/applications $out/share
    ln -s ${heroic-unwrapped}/share/icons $out/share
  '';

  meta = heroic-unwrapped.meta;
}
