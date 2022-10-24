" Return the file and optional target within that file specified
" by a line such as:
" load("//support/bazel/rule/spark:rules.bzl", "z_spark_prove_test")
" this returns file -> "support/bazel/rule/spark/rules.bzl" target -> "z_spark_prove_test"
" if the load statement imports multiple targets then the returned target is v:null
fu! bazeljump#GetBazelLoadTarget(line) abort
  let l:line = a:line
  if l:line =~# '^load("//'
    if l:line =~# '\.bzl", "[^"]*")'
      let l:target = substitute(l:line, '.*\.bzl", "\([^"]*\)").*', '\1', '')
    else
      let l:target = v:null
    endif
    let l:line = substitute(l:line, '^load("//\([^"]*\)".*', '\1', '')
    if l:line =~# '^[^:]*:[^.]*\.bzl'
      let l:file = substitute(l:line, ':', '/', '')
      return { 'file': l:file, 'target': l:target }
    else
      throw "Unrecognized bazel file: " .. l:line
    endif
  else
    return v:null
  endif
endfunction

fu! bazeljump#JumpToTargetWithinFile(target) abort
  call search("[() ]" .. a:target .. "[() ]", "s")
  call search("^" .. a:target .. "[() ]", "s")
  call search('name = "' .. a:target .. '"', "s")
endfunction

fu! bazeljump#GetJumpForTarget(target) abort
  let l:line = search('^load("[^"]*".*"' .. a:target .. '".*)', 'n')
  if l:line == 0
    let l:jump = {'file': v:null} 
  else
    let l:jump = bazeljump#GetBazelLoadTarget(getline(l:line))
    if l:jump is v:null
      throw "Unable to find target"
    endif
  endif
  let l:jump['target'] = a:target
  return l:jump
endfunction

fu! bazeljump#JumpToBazelDefinition() abort
  let l:line = getline('.')
  let l:jump = bazeljump#GetBazelLoadTarget(l:line)
  if l:jump is v:null
    if l:line =~# '^ *\([a-zA-Z_]* = \[\)\?"[a-zA-Z_/:.]*"'
      let l:target = substitute(l:line, '^[^/:]*', '', '')
      let l:target = substitute(l:target, '[,"\]]*$', '', '')
      if l:target =~# '^//'
        let l:jump = {'file': substitute(l:target, '//\([^:]*\).*', '\1', '') . "/BUILD.bazel"}
        if l:target =~# '^//.*:.*'
          let l:jump['target'] = substitute(l:target, '^[^:]*:', '', '')
        else
          let l:jump['target'] = substitute(l:target, '^.*/', '', '')
        endif
      elseif l:target =~# '^:'
        let l:jump = {'file': v:null, 'target': substitute(l:target, '^[^:]*:', '', '')} 
      else
        throw "Unrecognized target " . l:target
      endif
    elseif l:line =~# '^[a-zA-Z_]*('
      let l:target = substitute(l:line, '(.*', '', '')
      let l:jump = bazeljump#GetJumpForTarget(l:target)
    elseif l:line =~# '^ *[a-zA-Z_]* = [a-zA-Z_]*'
      let l:target = substitute(l:line, '^ *[a-zA-Z_]* = ', '', '')
      let l:target = substitute(l:target, '\(^[a-zA-Z_]*\).*$', '\1', '')
      let l:jump = bazeljump#GetJumpForTarget(l:target)
    else
      throw "Unrecognized line"
    endif
  endif
  if !(l:jump['file'] is v:null)
    if !(filereadable(l:jump['file']))
      throw "No such file " . l:jump['file']
    endif
    call better_gf#Openfile(l:jump['file'])
  endif
  if !(l:jump['target'] is v:null)
    call bazeljump#JumpToTargetWithinFile(l:jump['target'])
  endif
endfunction
