with import <nixpkgs> { };

let
  proxyCert = ../proxy.crt;

  broken = (import <nixpkgs> {
    config = {allowBroken = true;};
  });

in
{
  allowUnfree = true;
  allowBroken = false;
  build-use-sandbox = true;

  # nix.extraOptions = ''
  #   gc-keep-outputs = true
  #   gc-keep-derivations = true
  # '';

  packageOverrides = super: with super; let self = super.pkgs; in rec {
    # This is a fake package used to define what I want to install;
    # install/update it with `nix-env -i macos`
    macos = buildEnv {
      name = "macos";
      extraOutputsToInstall = [ "man" ];
      paths = [
        bashInteractive
        cacert
        cntlm
        coreutils # -prefixed # Starts with g
        dcfldd # ldd
        ditaa
        emacsMacport
        findutils
        # firefox
        fish
        ghostscript
        gitAndTools.gitFull
        gnupg
        graphviz
        hunspell
        #inkscape
        #iterm2
        #mytexlive
        texlive.combined.scheme-small
        nano
        ncurses
        pandoc
        wget
        #scudcloud # slack client
        xpdf

        # Archives
        atool
        p7zip
        unrar

        # Spark & Cassandra
        cassandra
        #liquibase
        sbt
        #scala_2_11
        #spark

        # Other development; libraries that are needed for compilation
        gmp.dev
        libcxx
        libressl
        openssl
        postgresql
        postgresql.lib
        postgresql_jdbc # for liquibase
        zlib
        zlib.dev

        # Haskell development
        ghc
        cabal-install
        cabal2nix
        # my-multi-ghc-travis
        stack
        haskellPackages.stylish-haskell
        haskellPackages.pointfree
        haskellPackages.structured-haskell-mode
        # haskellPackages.haskell-docs
        haskellPackages.hasktags
        haskellPackages.hlint
        haskellPackages.hdevtools
        haskellPackages.jbi

        # Cloud stuff
        ansible
        awscli
        awless
        terraform_0_11-full
        #terraform-docs
        plantuml
        #go2nix

        #nix-exec
        nix
        nix-repl
        nixbang
        #nox

      ];
    };

    cntlm = super.cntlm.overrideAttrs (attrs: rec {
      buildInputs = [ self.gcc ] ++ attrs.buildInputs ;
      meta = attrs.meta // (with stdenv.lib; {
        platforms = platforms.darwin;
      });
    });

    curl = super.curl.override { sslSupport = true; };

    wget = super.wget.override { openssl = openssl; };

    # mesos has trouble building, as clang can't seem to find jni to
    # build.
    spark = super.spark.override { mesosSupport = false; };

    plantuml = super.plantuml.overrideAttrs (attrs: rec {
      version = "1.2018.1";
      name = "plantuml-${version}";

      src = fetchurl {
        url = "mirror://sourceforge/project/plantuml/${version}/plantuml.${version}.jar";
        sha256 = "10a859bcf2f21c677d3c32d1cb70627529a0065fb7d766243a0a8a45cd320b27";
      };
    });

    cassandra = super.cassandra.overrideAttrs (attrs: rec {
      version = "3.11.0";
      name = "cassandra-${version}";
      src = fetchurl {
        url = "mirror://apache/cassandra/${version}/apache-${name}-bin.tar.gz";
        sha256  = "19sgsi0l1fh4v40dd0zxjfwaqh43wnwrsl9ka29czlib82dvk5ym";
      };
    });

    # myansible = self.python27Packages.ansible.overrideAttrs (attrs: rec {
    #   propagatedUserEnvPkgs = attrs.propagatedBuildInputs ;
    # });

    # ansibleEnv = python27Packages.withPackages (ps: [ps.boto ps.boto3]);

    # Everything within texlive.combined.scheme-small except xetex
    mytexlive = super.texlive.combine {
      inherit (super.texlive)
        collection-basic
        collection-latex
        collection-latexrecommended
        collection-metapost
        ec
        eurosym
        lm
        lualibs
        luaotfload
        luatexbase
        revtex
        synctex
        times
        tipa
        ulem
        upquote
        zapfding
        babel-basque
        hyphen-basque
        babel-czech
        hyphen-czech
        babel-danish
        hyphen-danish
        babel-dutch
        hyphen-dutch
        babel-english
        hyphen-english
        babel-finnish
        hyphen-finnish
        babel-french
        hyphen-french
        babel-german
        hyphen-german
        babel-hungarian
        hyphen-hungarian
        babel-italian
        hyphen-italian
        babel-norsk
        hyphen-norwegian
        babel-polish
        hyphen-polish
        babel-portuges
        hyphen-portuguese
        babel-spanish
        hyphen-spanish
        babel-swedish
        hyphen-swedish;
      };

    my-multi-ghc-travis = self.multi-ghc-travis.overrideAttrs (attrs: rec {
      installPhase = ''
          mkdir -p $out/bin
          ghc -O --make make_travis_yml.hs -o $out/bin/make-travis-yml
        '';
    });

    haskellPackages = super.haskellPackages.override {
      overrides = self: super: {
        dev-wl-pprint-text = self.callPackage ../../Haskell/wl-pprint-text {};

        # conduit_1_3_0 = pkgs.haskell.lib.addBuildDepend
        #   super.conduit_1_3_0
        #   super.resourcet_1_2_0;
        foundation = pkgs.haskell.lib.dontCheck super.foundation;
        # quickcheck-instances_0_3_16 = pkgs.haskell.lib.addBuildDepend
        #   super.quickcheck-instances_0_3_16
        #   self.QuickCheck_2_10_1;
        text-short = pkgs.haskell.lib.dontCheck super.text-short;
        # cassava_0_5_1_0 = pkgs.haskell.lib.addBuildDepend
        #   (pkgs.haskell.lib.disableCabalFlag
        #         (pkgs.haskell.lib.dontCheck super.cassava_0_5_1_0)
        #         "bytestring--lt-0_10_4")
        #   self.text-short;
        # streaming-cassava = pkgs.haskell.lib.addBuildDepend
        #   super.streaming-cassava
        #   self.cassava_0_5_1_0;
        # statistics_0_14_0_2 = pkgs.haskell.lib.dontCheck super.statistics_0_14_0_2;
        # criterion_1_2_3_0 = pkgs.haskell.lib.addBuildDepends
        #   (pkgs.haskell.lib.dontCheck super.criterion_1_2_3_0)
        #   [self.statistics_0_14_0_2 self.cassava_0_5_1_0];
        # testbench = pkgs.haskell.lib.addBuildDepends
        #   super.testbench
        #   [self.criterion_1_2_3_0 self.statistics_0_14_0_2 ];
        # servant-docs_0_11_1 = pkgs.haskell.lib.addBuildDepend
        #   super.servant-docs_0_11_1
        #   super.servant_0_12_1;
        };
    };

#configureFlags

    # haskellEnvFun = { withHoogle ? false, compiler ? null, name }:
    #   let hp = if compiler != null
    #              then super.haskell.packages.${compiler}
    #              else haskellPackages;

    #       ghcWith = if withHoogle
    #                   then hp.ghcWithHoogle
    #                   else hp.ghcWithPackages;

    #   in super.buildEnv {
    #     name = name;
    #     paths = [(ghcWith myHaskellPackages)];
    #   };

    profiledHaskellPackages = self.haskellPackages.override {
      overrides = self: super: {
        mkDerivation = args: super.mkDerivation (args // {
          enableLibraryProfiling = true;
        });
      };
    };

    # zulu = self.zulu.override {
    #   overrides = super
    # };

    cacert =
      if builtins.pathExists proxyCert
      then
        let
          extraBuild =
            ''
              cat $proxySrc ca-bundle.crt >> ca-bundle.crt.tmp
              mv ca-bundle.crt.tmp ca-bundle.crt
            '';
        in
          pkgs.lib.overrideDerivation super.cacert (attrs: {
            proxySrc = proxyCert;

            buildPhase =
              attrs.buildPhase + extraBuild;
          })
      else
        super.cacert;

    jre = super.jre8;
    jdk = super.jdk8;

    # terraform-docs = buildGoPackage rec {
    #   name = "terraform-docs-${version}";
    #   version = "0.3.0";

    #   goPackagePath = "github.com/segmentio/terraform-docs";
    #     src = fetchFromGitHub {
    #     owner = "segmentio";
    #     repo = "terraform-docs";
    #     rev = "v${version}";
    #     sha256 = "1qv9lxqx7m18029lj8cw3k7jngvxs4iciwrypdy0gd2nnghc68sw";
    #   };

    #   goDeps = ./deps.nix;

    #   buildFlags = "--tags release";
    # }

  };

}
