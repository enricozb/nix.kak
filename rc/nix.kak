hook global WinSetOption filetype=nix %{
  require-module nix-ext

  map -docstring "fix git sha256" buffer nix-fix-sha256 g ': nix-fix-sha256-git<ret>'
}

provide-module nix-ext %{
  declare-option -hidden str nix_sha256

  declare-user-mode nix-fix-sha256

  define-command nix-fix-sha256 -docstring "fix sha256" %{
    enter-user-mode nix-fix-sha256
  }

  define-command -hidden nix-fix-sha256-git -docstring "fix git sha256" %{
    evaluate-commands -draft %{
      execute-keys 's\w+\h*=[^\n]*;<ret>'

      set-option buffer nix_sha256 %sh{
        git_url="$(python -c "$kak_selections print(f'https://github.com/{owner}/{repo}/archive/{rev}.tar.gz')")"

        nix-prefetch-url 2>/dev/null --type sha256 --unpack "$git_url"
      }
    }

    execute-keys 's(?<=sha256 = ")[^"]*(?=";)'
    execute-keys <ret>
    execute-keys "c%opt{nix_sha256}<esc>"
  }
}
