###########
# helpers #
###########

def basedir [] {
  if ($env.SNIP_SNIPDIR? | is-not-empty) {
    $env.SNIP_SNIPDIR
  } else if ($env.XDG_CONFIG_HOME? | is-not-empty) {
    [$env.XDG_CONFIG_HOME snip] | path join
  } else {
    [$env.HOME .config snip] | path join
  }
}

def bat-supported [] {
  [as adb ads gpr envvars htaccess HTACCESS htgroups HTGROUPS htpasswd HTPASSWD .htaccess .HTACCESS .htgroups .HTGROUPS .htpasswd .HTPASSWD httpd.conf /etc/apache2/**/*.conf /etc/apache2/sites-*/**/* /etc/httpd/conf/**/*.conf applescript script editor s S adoc ad asciidoc asa authorized_keys pub authorized_keys2 awk bat cmd bib sh bash zsh ash .bash_aliases .bash_completions .bash_functions .bash_login .bash_logout .bash_profile .bash_variables .bashrc .profile .textmate_init .zlogin .zlogout .zprofile .zshenv .zshrc PKGBUILD ebuild eclass **/bat/config *.ksh *.kshrc /etc/os-release /var/run/os-release /etc/profile bashrc *.bashrc bash_profile *.bash_profile bash_login *.bash_login bash_logout *.bash_logout zshrc *.zshrc zprofile *.zprofile zlogin *.zlogin zlogout *.zlogout zshenv *.zshenv c cs csx cpp cc cp cxx c++ h hh hpp hxx h++ inl ipp *.h cabal cfml cfm cfc clj cljc cljs edn CMakeLists.txt cmake h.in hh.in hpp.in hxx.in h++.in CMakeCache.txt coffee Cakefile coffee.erb cson cmd-help help cpuinfo tab crontab cron.d cr css css.erb css.liquid d di dart sources.list diff patch *.debdiff Dockerfile dockerfile .Dockerfile Containerfile .env .env.dist .env.local .env.sample .env.example .env.template .env.test .env.test.local .env.testing .env.dev .env.development .env.development.local .env.prod .env.production .env.production.local .env.dusk.local .env.staging .env.default .env.defaults .envrc .flaskenv env env.example env.sample env.template ex exs elm eml msg mbx mboxz /var/spool/mail/* /var/mail/* erl hrl Emakefile emakefile escript fs fsi fsx *.fs fish f F f77 F77 for FOR fpp FPP f90 F90 f95 F95 f03 F03 f08 F08 namelist fstab crypttab mtab gd attributes gitattributes .gitattributes /Users/colombos/.config//git/attributes /Users/colombos/.config/git/attributes COMMIT_EDITMSG MERGE_MSG TAG_EDITMSG gitconfig .gitconfig .gitmodules /Users/colombos/.config//git/config /Users/colombos/.config/git/config exclude gitignore .gitignore /Users/colombos/.config//git/ignore /Users/colombos/.config/git/ignore .git gitlog .mailmap mailmap git-rebase-todo vs gs vsh fsh gsh vshader fshader gshader vert frag geom tesc tese comp glsl mesh task rgen rint rahit rchit rmiss rcall gp gpl gnuplot gnu plot plt go go.mod go.work go.sum graphql graphqls gql dot DOT gv groff troff 1 2 3 4 5 6 7 8 9 groovy gvy gradle Jenkinsfile group hs show-nonprintable hosts html htm shtml xhtml asp html.eex html.leex yaws htm.j2 html.j2 xhtml.j2 xml.j2 rails rhtml erb html.erb adp twig html.twig http idr ini INI inf INF reg REG lng cfg CFG desktop url URL .editorconfig .coveragerc .pylintrc .gitlint .hgrc hgrc **/.aws/credentials **/.aws/config /etc/letsencrypt/renewal/*.conf /etc/wireguard/*.conf java bsh properties jsp htc js mjs jsx babel es6 cjs *.pac js.erb j2 jinja2 jinja jq json sublime-settings sublime-menu sublime-keymap sublime-mousemap sublime-theme sublime-build sublime-project sublime-completions sublime-commands sublime-macro sublime-color-scheme ipynb Pipfile.lock *.jsonl *.jsonc *.jsonld *.geojson *.ndjson flake.lock *.sarif jsonnet libsonnet libjsonnet jl known_hosts known_hosts.old kt kts tex ltx lean less css.less lisp cl clisp l mud el scm ss lsp fasl sld lhs ls Slakefile ls.erb ll log lua *.nse make GNUmakefile makefile Makefile makefile.am Makefile.am makefile.in Makefile.in OCamlMakefile mak mk man md mdown markdown markdn *.mkd matlab mediawiki wikipedia wiki meminfo build conf.erb nginx.conf mime.types fastcgi_params scgi_params uwsgi_params nginx.conf mime.types /etc/nginx/**/*.conf /etc/nginx/sites-*/**/* nim nims nimble ninja nix nsi nsh bnsi bnsh nsdinc m mm ml mli mll mly odin org pas p dpr passwd pl pc pm pmc pod t php php3 php4 php5 php7 phps phpt phtml txt ps1 psm1 psd1 proto protobuf protodevel pb.txt proto.text textpb pbtxt prototxt textproto pp epp purs py py3 pyw pyi pyx pyx.in pxd pxd.in pxi pxi.in rpy cpy SConstruct Sconstruct sconstruct SConscript gyp gypi Snakefile vpy wscript bazel bzl *.xsh *.xonshrc qml qmlproject R r Rprofile rkt rd rego re requirements.txt requirements.in pip resolv.conf rst rest robot resource rb Appfile Appraisals Berksfile Brewfile capfile cgi Cheffile config.ru Deliverfile Fastfile fcgi Gemfile gemspec Guardfile irbrc jbuilder Podfile podspec prawn rabl rake Rakefile Rantfile rbx rjs ruby.rail Scanfile simplecov Snapfile thor Thorfile Vagrantfile haml rxml builder slim skim rs *.ron sls sass scala sbt sc *.mill scss csv sml cm sig sol sql ddl dml erbsql sql.erb ssh_config **/.ssh/config sshd_config strace styl stylus svlt svelte swift syslog sv svh vh tsv tcl tf tfvars hcl sty cls textile todo.txt done.txt toml tml Cargo.lock Gopkg.lock Pipfile pdm.lock poetry.lock uv.lock ts mts cts tsx typ varlink v V vhd vhdl vho vht vimhelp vim vimrc gvimrc .vimrc .gvimrc .exrc .nvimrc _vimrc _gvimrc _exrc vue vy wgsl yasm nasm asm inc mac xml xsd xslt tld dtml rng rss opml svg xaml *.csproj *.vbproj *.props *.targets yaml yml sublime-syntax CITATION.cff .clang-format fish_history zig]
}

def snips [] {
  glob --no-dir $"(basedir)/**/*" | each {|file|
    let info = $file | path split | last 2
    {
      category: ($info | first)
      name: ($info | last)
      content: (open -r $file)
      path: $file
    }
  }
}

def _bat_ [] {
  let selected = $in
  let extension = $selected.path | path parse | get extension
  let lang = if ($extension in (bat-supported)) {$extension} else {'txt'}
  $selected.content | bat --decorations never --color always -l $lang
}

def fuzzyfind [] {
  let l = $in
  (
    $in
    | sk 
    --prompt 'choose a snippet: '
    --preview-window right:70% 
    --format { [$in.category $in.name] | path join }
    --preview { $in | _bat_ }
  )
}

##########
# public #
##########

# put snippet to cmdline
export def main [] { commandline edit -r (snips | fuzzyfind | get content) }

# bat snip
export def show [] { snips | fuzzyfind | _bat_ }

# copy snip to clipboard
export def cp [] { snips | fuzzyfind | get content | pbcopy }

# edit snip
export def edit [] { nu -c $"($env.editor) ((snips | fuzzyfind).path)" }

# manage snips
export def manage [] { nu -c $"($env.editor) (basedir)" }

# list snips
export def ls [] { snips }
