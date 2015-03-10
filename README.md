![Tuna](https://raw.githubusercontent.com/dealforest/Tuna/master/images/tuna.png)

### public beta version

Xcode plugin that provides easy set breakpoint with action.

![Capture](https://raw.githubusercontent.com/dealforest/Tuna/master/images/capture.png)

## Installation
Download the project and build it, and then relaunch Xcode.
Tuna will be installed in `~/Library/Application Support/Developer/Shared/Xcode/Plug-ins` automatically.

If you want to uninstall, remove Tuna.xcplugin in the `Plug-ins` directory.

## Requirements

* Xcode 6.0+ 

## より便利に使うために

### XVim
~/.xvimrc
```
vnoremap <enter> :xcmenucmd Set Print Breakpoint<CR>
noremap \<enter> :xcmenucmd Set Backtrace Breakpoint<CR>
```

### shortcut
![Capture](https://raw.githubusercontent.com/dealforest/Tuna/master/images/settings.png)

---

## Contact

### Creator

- [Toshihiro Morimoto](http://github.com/dealforest) ([@dealforest](https://twitter.com/dealforest))

### License

Crying is released under the MIT license. See LICENSE for details.
