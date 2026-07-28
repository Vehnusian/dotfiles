# Cheatsheet

Leader is `<space>`. Localleader is `\` (used by LaTeX).

**You do not need to memorise this.** Press `<space>` and wait — which-key shows every
available next key. `<leader>sk` fuzzy-searches all keymaps live, which is always more
current than this file.

## Starting up

```powershell
nvim                 # dashboard
nvim file.py         # open a file
nvim .               # open a directory (file explorer)
cd ~/Desktop/Poly; nvim .
```

Exit with `<leader>qq` (quit all) or `:q`. If you get stuck in a weird mode, `<Esc>` twice
gets you back to normal mode.

## The absolute minimum Vim

| Key | Does |
| --- | --- |
| `i` | Insert mode (type normally). `<Esc>` to leave |
| `:w` | Save. `:q` quit, `:wq` save+quit, `:q!` discard |
| `dd` `yy` `p` | Delete line, copy line, paste |
| `u` / `<C-r>` | Undo / redo |
| `/text` then `n` | Search, jump to next match |
| `gg` / `G` | Top / bottom of file |
| `<C-o>` / `<C-i>` | Jump back / forward (after a `gd`) |

## Files, search, navigation

| Key | Does |
| --- | --- |
| `<leader><space>` | Find files in project |
| `<leader>ff` | Find files |
| `<leader>fr` | Recent files |
| `<leader>fg` | Find git-tracked files |
| `<leader>/` | Live grep across the project |
| `<leader>e` | File explorer sidebar |
| `<leader>sk` | **Search all keymaps** |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<leader>bd` | Close buffer |
| `` <leader>` `` | Toggle to last buffer |
| `<C-h/j/k/l>` | Move between split windows |
| `<leader>-` / `<leader>\|` | Split below / right |
| `<C-/>` | Toggle terminal |

## Code (LSP — works in Python)

| Key | Does |
| --- | --- |
| `K` | Hover docs for symbol under cursor |
| `gd` | Go to definition |
| `gr` | Find references |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `gK` | Signature help |
| `<leader>ca` | Code action (quick fixes, imports) |
| `<leader>cr` | Rename symbol everywhere |
| `<leader>cd` | Show diagnostic on this line |
| `]d` / `[d` | Next / previous diagnostic |
| `]e` / `[e` | Next / previous error |
| `<leader>cl` | LSP info (is the server attached?) |
| `<leader>cm` | Mason (manage LSP servers) |

Formatting happens automatically on `:w` via ruff.

## Python

| Key | Does |
| --- | --- |
| `<leader>cv` | Select virtualenv (point basedpyright at a `uv` `.venv`) |

### Tests

| Key | Does |
| --- | --- |
| `<leader>tr` | Run nearest test |
| `<leader>tt` | Run current file |
| `<leader>tT` | Run all test files |
| `<leader>ts` | Toggle test summary sidebar |
| `<leader>to` | Show output of last test |
| `<leader>tw` | Watch file, re-run on save |
| `<leader>td` | Debug nearest test |

### Debugging

| Key | Does |
| --- | --- |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Start / continue |
| `<leader>di` | Step into |
| `<leader>dO` | Step over |
| `<leader>do` | Step out |
| `<leader>du` | Toggle debugger UI |
| `<leader>de` | Evaluate expression under cursor |
| `<leader>dr` | Toggle REPL |
| `<leader>dt` | Terminate session |
| `<leader>dPt` | Debug the test method under cursor |

Typical loop: `<leader>db` on a line, `<leader>dc` to run, `<leader>du` to see
variables/stack, `<leader>dO` to step, `<leader>dt` to stop.

## LaTeX (localleader is `\`)

| Key | Does |
| --- | --- |
| `\ll` | Compile |
| `\lv` | Open/jump to spot in SumatraPDF |
| `\le` | Error list |
| `\lo` | Raw compiler output |
| `\lc` | Clean aux files |

Tectonic has no continuous mode, so **`:w` rebuilds** (autocmd) and SumatraPDF reloads
itself. Double-click in the PDF jumps back to the source line.

## Git

| Key | Does |
| --- | --- |
| `<leader>gg` | Lazygit (whole UI: stage, commit, push, branch, log) |
| `<leader>gb` | Blame current line |
| `<leader>gf` | History of current file |
| `]h` / `[h` | Next / previous change hunk |

In lazygit: `<space>` stage, `c` commit, `P` push, `p` pull, `q` quit, `?` help.

## Managing the setup

| Command | Does |
| --- | --- |
| `:Lazy` | Plugin manager — `U` update, `S` sync, `x` clean |
| `:Mason` | Install/remove LSP servers and tools |
| `:checkhealth` | Diagnose problems |
| `:LazyExtras` | Browse language extras (we declare ours in `lua/config/lazy.lua`) |

## Shell helpers (PowerShell profile)

| Command | Does |
| --- | --- |
| `texb main.tex` | Build once with tectonic |
| `texw main.tex` | Watch and rebuild on change |
| `New-TexDoc name` | Scaffold a new LaTeX document |
| `y` | yazi file manager (cds to where you quit) |
| `lg` | lazygit |
| `ll` / `la` / `lt` | List / all / tree |
| `g` `py` `c` | git / python / code |
| `gs ga gc gp gl gd gco` | git status/add/commit/push/log/diff/checkout |
