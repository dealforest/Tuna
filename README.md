![Tuna](https://raw.githubusercontent.com/dealforest/Tuna/master/images/tuna.png)

### public beta version

Xcode plugin that provides easy set breakpoint with action.


## Usage

### Set breakpoint with backtrace action
1. You will move the cursor to the location where you want to output backtrace.
2. You press the shortcut key(`Command + Shift + ;`) or the menu(`Debug -> Tuna -> Set Backtrace Breakpoint`)

![Capture](https://raw.githubusercontent.com/dealforest/Tuna/master/images/capture_backtrace.png)

### Set breakpoint with print action
1. You select the variable that You want to output.
2. You press the shortcut key(`Command + Shift + '`) or the menu(`Debug -> Tuna -> Set Print Breakpoint`)

in the case of select `cell.textLabel.text`

![Capture](https://raw.githubusercontent.com/dealforest/Tuna/master/images/capture_print.png)

## Installation
Download the project and build it, and then relaunch Xcode.
Tuna will be installed in `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins` automatically.

If you want to uninstall, remove Tuna.xcplugin in the `Plug-ins` directory.

## Requirements

* Xcode 6.0+ 

## Customize shortcuts

### XVim
~/.xvimrc
```
vnoremap <enter> :xcmenucmd Set Print Breakpoint<CR>
noremap \<enter> :xcmenucmd Set Backtrace Breakpoint<CR>
```

### System Preferences
![Capture](https://raw.githubusercontent.com/dealforest/Tuna/master/images/settings.png)

shortcut word
* 「Debug->Tuna->Set Backtrace Breakpoint」
* 「Debug->Tuna->Set Print Breakpoint」

---

## Contact

### Creator

- [Toshihiro Morimoto](http://github.com/dealforest) ([@dealforest](https://twitter.com/dealforest))

### Changes

See [Releases](https://github.com/dealforest/Tuna/releases).

### License

Tuna is released under the MIT license. See LICENSE for details.
