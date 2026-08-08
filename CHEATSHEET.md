# Cheatsheet

Editor is [Positron](https://positron.posit.co) — a data-science IDE built on VS Code, so
every standard VS Code shortcut works. `Ctrl+Shift+P` opens the command palette, which is
the fastest way to find anything by name.

## Opening things

```powershell
positron .              # open current folder
positron file.py        # open a file
p .                     # 'p' alias from the profile
cd ~/Desktop/Poly; p .
```

## Everyday keys

| Key | Does |
| --- | --- |
| `Ctrl+Shift+P` | Command palette — search every command by name |
| `Ctrl+P` | Quick-open a file by name |
| `Ctrl+Shift+F` | Search across the whole project |
| `Ctrl+B` | Toggle sidebar |
| `` Ctrl+` `` | Toggle terminal |
| `Ctrl+S` | Save (formats with ruff automatically) |
| `Ctrl+/` | Comment / uncomment |
| `Ctrl+D` | Select next occurrence (multi-cursor) |
| `Alt+↑` / `Alt+↓` | Move line up / down |
| `Ctrl+Shift+E` | File explorer |

## Reading and navigating code

| Key | Does |
| --- | --- |
| `F12` | Go to definition |
| `Alt+F12` | Peek definition inline |
| `Shift+F12` | Find all references |
| `Ctrl+Click` | Jump to whatever you clicked |
| `Alt+←` / `Alt+→` | Navigate back / forward |
| `F2` | Rename symbol everywhere |
| `Ctrl+.` | Quick fix / code action |
| `Ctrl+Shift+O` | Jump to a symbol in this file |
| `F8` | Next problem/error |

Hovering the mouse over anything shows its documentation and type.

## Python

Positron has built-in Python support — no extension needed. The **Console** (bottom panel)
is a live session, and the **Variables** pane shows your DataFrames and objects as they
exist in memory.

| Key | Does |
| --- | --- |
| `Ctrl+Enter` | Run selection / current line in the console |
| `F5` | Start debugging |
| `F9` | Toggle breakpoint |
| `F10` / `F11` | Step over / step into |
| `Shift+F5` | Stop debugging |

Click a DataFrame in the Variables pane to open the data viewer — sortable, filterable,
the main reason to use Positron over plain VS Code.

Plots (`matplotlib`, `seaborn`, `plotly`) render in the Plots pane; use its history arrows
to step back through earlier figures.

Formatting and import-sorting run on save via ruff.

For the full debug configurations, copy them into the project first:

```powershell
mkdir .vscode; cp ~/dotfiles/positron/launch.json .vscode/launch.json
```

## LaTeX

Saving a `.tex` file rebuilds it with tectonic; SumatraPDF reloads on its own.

| Key | Does |
| --- | --- |
| `Ctrl+Alt+B` | Build now |
| `Ctrl+Alt+V` | Open / forward-search to the PDF |

Double-clicking in the PDF jumps back to the matching source line.

## Git

The Source Control panel (`Ctrl+Shift+G`) handles staging, committing and pushing. For
anything more involved, `lg` in the terminal opens lazygit:

`<space>` stage · `c` commit · `P` push · `p` pull · `q` quit · `?` help

## Shell helpers (PowerShell profile)

| Command | Does |
| --- | --- |
| `p` | Open Positron |
| `texb main.tex` | Build once with tectonic |
| `texw main.tex` | Watch and rebuild on change |
| `New-TexDoc name` | Scaffold a new LaTeX document |
| `y` | yazi file manager (cds to where you quit) |
| `lg` | lazygit |
| `ll` / `la` / `lt` | List / all / tree |
| `g` `py` | git / python |
| `gs ga gc gp gl gd gco` | git status/add/commit/push/log/diff/checkout |
