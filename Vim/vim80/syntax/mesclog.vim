" Vim syntax file for MESc log files

let g:MEScStarted_pattern = "MESc GUI started\..*"
let g:MeasStarted_pattern = "sigMeasureRunning()"
let g:MeasFinished_pattern = "sigMeasureDone()"
let g:mesc_fold_level = "0"

syn match		LogRow				display "^[ \t]*<[ 0-9\.\:\-]*>[ \t]\[[A-Z]*\][ \t]<[a-zA-Z0-9]*>[ \t].*" contains=LogTime,@LogType,MEScProject,MEScClassText,MEScStarted,MescSettings,MEScFinished,MEScMeasStarted,MEScMeasFinished,MEScTextHexNumber,MEScTextNumber
syn match		LogTime				display contained "^[ \t]*<[ 0-9\.\:\-]*>" nextgroup=LogType
syn cluster		LogType				contains=LogTrace,LogDebug,LogInfo,LogTitle,LogWarning,LogError,LogFatal
syn match		LogTrace			display contained "[ \t]\[TRACE\][ \t]"hs=e-7,he=e-1 nextgroup=MEScProject
syn match		LogDebug			display contained "[ \t]\[DEBUG\][ \t]"hs=e-7,he=e-1 nextgroup=MEScProject
syn match		LogInfo				display contained "[ \t]\[INFO\][ \t]"hs=e-6,he=e-1 nextgroup=MEScProject
syn match		LogTitle			display contained "[ \t]\[TITLE\][ \t]"hs=e-7,he=e-1 nextgroup=MEScProject
syn match		LogWarning			display contained "[ \t]\[WARNING\][ \t]"hs=e-9,he=e-1 nextgroup=MEScProject
syn match		LogError			display contained "[ \t]\[ERROR\][ \t]"hs=e-7,he=e-1 nextgroup=MEScProject
syn match		LogFatal			display contained "[ \t]\[FATAL\][ \t]"hs=e-7,he=e-1 nextgroup=MEScProject
syn match		MEScProject			display contained "<[a-zA-Z0-9]*>[ \t]" nextgroup=MEScClassText
syn match		MEScClassText		display contained "[a-zA-Z0-9:]*::[^:]*():.*" contains=MEScClass,MEScFunc,MEScTextHexNumber,MEScTextNumber
syn match		MEScClass			display contained "[a-zA-Z0-9:]*::" nextgroup=MEScFunc
syn match		MEScFunc			display contained "[^:]*():"he=e-1
syn match		MEScStarted			display contained "MESc GUI started\..*"
"syn match		MEScStarted			display contained "$(g:MEScStarted_pattern)"
syn match		MEScSettings		display contained "using settings from:.*"
syn match		MEScFinished		display contained "MESc Qt GUI exited.*"
syn match		MEScMeasStarted		display contained "sigMeasureRunning()"
syn match		MEScMeasFinished	display contained "sigMeasureDone()"
syn match		MEScTextHexNumber  	display contained "\<0[xX][0-9a-fA-F]\+\>"
syn match		MEScTextNumber  	display contained "[-]\?[0-9]\.[0-9]\+[eE][+-][0-9]\+\|[-]\?\<[0-9][\.0-9]*\>"

"command! -nargs=0 MakeRCTraceFolding :call MakeRCTraceFoldingFunc()
"function! MakeRCTraceFoldingFunc()
"  syn region      TrcEntryExit start=/^[ \t]*[0-9\.\:\-]*[ \t]ENTRY[ \t]/ end=/^[ \t]*[0-9\.\:\-]*[ \t]EXIT[ \t]/ contains=TrcEntryExit,MEScClass,LogRowStart,TrcFilePos fold
"  "syn sync fromstart
"  "syn sync maxlines=100
"  set foldlevel=8
"  set foldmethod=syntax
"  set foldcolumn=6
"endfunction

function! SearchMEScStart(...)
    if a:0 > 0
        if a:1 == "b"
            execute "normal ?" . g:MEScStarted_pattern . ""
        endif
    else 
        execute "normal /" . g:MEScStarted_pattern . ""
    endif
endfunction

function! SearchStartOfDay(...)
    let current_line_number = line('.')

    if a:0 > 0
        if a:1 == "b"
            if current_line_number == 1
                return
            endif

            let prev_line = getline(current_line_number - 1)
            let prev_day = strpart(prev_line, 1, 10)

            normal gg
            execute "normal /" . prev_day . "/s-1"
        endif
    else
        let this_line = getline(current_line_number)
        let this_day = strpart(this_line, 1, 10)

        normal G

        execute "normal ?" . this_day . "?+1"
    endif
endfunction

map <F9> :call SearchMEScStart("b")
map <F10> :call SearchMEScStart()
map <C-F9> :call SearchStartOfDay("b")
map <C-F10> :call SearchStartOfDay()

"set mouse=n
"set foldmethod=marker
"set foldmarker=MESc\ GUI\ started.,MESc\ Qt\ GUI\ exited
"set foldmethod=expr
set foldexpr=MEScFoldLevel(v:lnum)
set foldcolumn=4
"set foldlevel=1000

function! MEScFoldLevel(lnum)
    let current_line = getline(a:lnum)
    let next_line = getline(a:lnum + 1)

    if current_line =~ g:MEScStarted_pattern
        let g:mesc_fold_level = ">1"
    elseif g:mesc_fold_level != "0"
        if next_line =~ g:MEScStarted_pattern
            let g:mesc_fold_level = "<1"
        else
            if current_line =~ g:MeasStarted_pattern
                let g:mesc_fold_level = "a1"
            elseif current_line =~ g:MeasFinished_pattern
                let g:mesc_fold_level = "s1"
            else
                let g:mesc_fold_level = "="
            endif
        endif
    endif

    return g:mesc_fold_level
endfunction

let b:current_syntax = "mesclog"

"hi clear

color elflord
" orange background for hlSearch:
"hi Search guibg=#ffaa33 guifg=black
" ping background for hlSearch:
"hi Search guibg=#ff66ff guifg=black
" green/cyan background for hlSearch:
hi Search guibg=#00ffdd guifg=black
hi Normal guifg=lightgray

"set background=dark

hi LogTime				ctermfg=Gray			guifg=#aaaaaa

hi LogTrace				ctermfg=Black			guifg=#aaaaaa
hi LogDebug				ctermfg=Black			guifg=#555555
hi LogInfo				ctermfg=Black			guifg=#555555
hi LogTitle				ctermfg=Green			guifg=#11aa11
hi LogWarning			ctermfg=Yellow			guifg=#eeaa00
hi LogError				ctermfg=Red				guifg=#ff0000
hi LogFatal				ctermfg=Red				guifg=#880000

hi MEScProject			ctermfg=Brown			guifg=#003080

hi MEScClass			ctermfg=Brown			guifg=#0055cc
hi MEScFunc				ctermfg=Brown			guifg=#1a90ff

hi MEScStarted									guifg=#000000				guibg=#ffff00
hi MEScSettings									guifg=#000000				guibg=#ffff00
hi MEScFinished									guifg=#000000				guibg=#aaaa00
hi MEScMeasStarted								guifg=#000000				guibg=#00ff00
hi MEScMeasFinished								guifg=#000000				guibg=#008800
hi MEScTextHexNumber							guifg=#ff00ff
hi MEScTextNumber								guifg=#ff00ff
hi FoldColumn                                   guifg=cyan                  guibg=black
hi Folded                                       guifg=cyan                  guibg=darkgrey
hi Visual                                                                   guibg=#777777
