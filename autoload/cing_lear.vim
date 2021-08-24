" Leaves the terminal in INSERT mode. I was unable to fix that; `stopinsert` et al just weren't
" cutting it for some reason.
function! cing_lear#terminal_clear()
   let l:scrollback = &scrollback
   set scrollback=1

   " Background any child-process. (No idea why <C-z> doesn't work.)
   let l:children = systemlist('pgrep -P '.b:terminal_job_pid)
   for pid in l:children[1:]
      call jobstart(['kill', '-STOP', pid])
   endfor

   sleep 500m

   " Space at the start of the command, plus additional space-return, prevents this from being added
   " to shell history. Requires `setopt histignorespace`.
   call chansend(&channel, " printf '\\n%.0s' {1..200}\<CR> \<CR>")

   if len(l:children) ># 1
      " This will still leave ` fg` in the immediate command-history until you enter another
      " command, unfortunately. Further, I can't figure out a solution that doesn't leave
      " '[1]  + continued' dumped to the terminal-buffer. /=
      call feedkeys("i\<C-l> fg\<CR>")
   else
      call feedkeys("i\<C-l>")
   endif

   " This would be a superior solution to the `fg` above, but it ... doesn't work *at all*, again
   " for reasons unknown.
   " for pid in l:children
   "    call jobstart(['kill', '-CONT', pid])
   " endfor

   exec "set scrollback=".l:scrollback
endfunction
