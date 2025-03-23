# Brainfuck-compatible Esoteric Language

*by CatMeowByte*

Minimal esoteric programming language based on Brainfuck with numeric arguments, direct jumps, and value setters.

Theoretically compatible with Brainfuck standards, though not yet extensively tested.

## Syntax

### Jumper
|Symbol|Usage|
|-|-|
|`<`|Move pointer backward|
|`>`|Move pointer forward|
|`#`|Jump pointer to the specified memory cell|

### Setter
|Symbol|Usage|
|-|-|
|`-`|Subtract from the current cell|
|`+`|Add to the current cell|
|`=`|Set the current cell to the specified number|

### Teleporter
|Symbol|Usage|
|-|-|
|`[`|If the current cell is zero, jump forward to the matching `]`|
|`]`|If the current cell is non-zero, jump backward to the matching `[`|

### Input/Output
|Symbol|Usage|
|-|-|
|`?`|Await a single character of input and store its Unicode value in the current cell|
|`!`|Output the character at the current cell|

## Notes
+ All commands operate by default with a value of 1 or followed by a number. Example:
  + `+` is the same as `+ 1`.
  + `> 3` moves the pointer forward by 3.
+ Whitespace is ignored.
+ Comments may be written only using lowercase letters a–z.

## License

This project is licensed under [GPLv3+](https://spdx.org/licenses/GPL-3.0-or-later.html "GNU General Public License version 3 or later").

## Contributing

This project follows the [HGG](https://catmeowbyte.github.io/heretic_git_guidelines "Heretic Git Guidelines").