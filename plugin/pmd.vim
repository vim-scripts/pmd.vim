" $Id: pmd.vim,v 1.1 2004/10/27 01:57:32 henry Exp $
"
" Name:             PMD plugin
" Description:      Integrates PMD using Vim quickfix mode
" Author:           Henry So, Jr. <henryso at panix dot com>
" Version:          1.0
" Modified:         26 October 2004
" License:          Released into the public domain.
"
" Usage:            Copy this file into the plugins directory if you want it
"                   to be automatically sourced.  Otherwise, :source it when
"                   you need it.
"
"                   To invoke PMD, either issue the command :Pmd or enter the
"                   appropriate key command (by default, this is <Leader>pmd).
"
"                   The :Pmd command may take one argument, the file or
"                   directory on which to run PMD.  If left out, PMD will run
"                   against the filename of the current buffer.  It does not
"                   save the current buffer first unless 'autowrite' is set.
"                   This is also the behavior when <Leader>pmd is used.
"
"                   Once invoked, the plugin will use the quickfix features of
"                   Vim to integrate with PMD.  See :help quickfix for more
"                   information.
"
" Configuration:    The default command for running PMD is "pmd".  This is not
"                   really a suitable default so you should set the Pmd_Cmd
"                   variable to the command you want to use.  For example:
"
"                       :let Pmd_Cmd = "/path/to/pmd/run.sh"
"
"                   To this command, the plugin will append the following
"                   arguments:
"
"                       - the file/directory against which to run PMD
"                       - the word 'text'
"                       - the PMD rulesets to use
"
"                   This is the usage of the run.sh and run.bat scripts
"                   included in PMD 2.0.
"
"                   The default PMD rulesets are
"
"                       - rulesets/basic.xml
"                       - rulesets/imports.xml
"                       - rulesets/unusedcode.xml
"
"                   These are completely arbitrary in that they are what I am
"                   currently using.  To change this, set the Pmd_Rulesets
"                   variable to the rulesets you want to use.  For example:
"
"                       :let Pmd_Rulesets = "rulesets/one.xml,rulesets/two.xml"
"
"                   The default key command to invoke BeanShell is <Leader>pmd.
"                   To change this keymapping, use :map to assign the key you
"                   want to <Plug>Pmd.  For example:
"
"                       :map <S-F4> <Plug>Pmd
"
" Acknowledgments:  This script owes its style to Yegappan Lakshmanan's
"                   taglist.vim and Anthony Kruize / Michael Geddes's
"                   ShowMarks.

if exists('loaded_pmd')
    finish
endif
let loaded_pmd = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim

" set-up defaults if necessary
if !exists('Pmd_Cmd')
    let Pmd_Cmd = "pmd"
endif

if !exists('Pmd_Rulesets')
    let Pmd_Rulesets = "rulesets/basic.xml,rulesets/imports.xml,rulesets/unusedcode.xml"
endif

if !hasmapto("<Plug>Pmd")
    map <unique> <Leader>pmd <Plug>Pmd
endif

" Function:     Pmd_Run
" Description:  Runs PMD on the specified file/directory or on the filename of
"               the current buffer if no argument is given.
function! s:Pmd_Run(...) "{{{1
  let l:old_cpoptions = &cpoptions
  let l:old_format = &errorformat
  set cpoptions-=F
  set errorformat=%f\	%l\	%m
  let l:tmpfile = tempname()
  if a:0 == 0
      let l:cmd = g:Pmd_Cmd . " " . expand("%") . " text " . g:Pmd_Rulesets
  else
      let l:cmd = g:Pmd_Cmd . " " . a:1 . " text " . g:Pmd_Rulesets
  endif
  exe "silent !" . l:cmd . " > " . l:tmpfile
  exe "cfile " . l:tmpfile
  call delete( l:tmpfile )
  let &cpoptions = l:old_cpoptions
  let &errorformat = l:old_format
endfunction "}}}

" Set up entry points: the command, the keymapping, and the menu.
if !exists(":Pmd")
    command -nargs=? -complete=file Pmd :call <SID>Pmd_Run(<f-args>)
endif

noremap <unique> <script> <Plug>Pmd <SID>Pmd_Run

noremenu <script> Plugin.Invoke\ Pmd <SID>Pmd_Run

noremap <silent> <SID>Pmd_Run :call <SID>Pmd_Run()<CR>

let &cpoptions = s:save_cpoptions
