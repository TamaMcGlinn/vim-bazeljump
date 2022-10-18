(Neo)Vim bazeljump
==================

(Neo)Vim plugin to be able to jump to definitions within and between bazel files. It would be better to do this with a languageserver, but the one I found was early experimental work and didn't work. So I hacked together what I needed with a few ugly regex replacements.

If it doesn't work for you, don't say I didn't warn you.

Provides bazeljump#JumpToBazelDefinition(). I recommend you map to it inside your vimrc/ftplugin/bzl.vim script:

```
nnoremap <silent> <buffer> gd :call bazeljump#JumpToBazelDefinition()<CR>
```

Installation
------------

Use your preferred plugin manager. For [Plug](https://github.com/junegunn/vim-plug):

```
Plug 'TamaMcGlinn/vim-bazeljump'
```
