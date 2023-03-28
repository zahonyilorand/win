" Vim syntax file for MESc log files

let g:MEScStarted_pattern = "MESc GUI started\..*"
let g:MeasStarted_pattern = "sigMeasureRunning()"
let g:MeasStarted2_pattern = "sigTestPatternRunning()"
let g:MeasFinished_pattern = "sigMeasureDone()"
let g:mesc_fold_level = "0"
let g:orig_pos_list = getpos('.')
let g:orig_window_last_line_number = line('w$')

syn match		LogRow				display "^[ \t]*<[ 0-9\.\:\-]*>[ \t]\[[A-Z]*\][ \t]<[a-zA-Z0-9]*>[ \t].*" contains=LogTime,@LogType,MEScProject,MEScClassText,MEScStarted,MEScSettings,MEScFinished,MEScIni,MEScMeasStarted,MEScMeasStarted2,MEScMeasFinished,MEScTextHexNumber,MEScTextNumber
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
syn match		MEScClassText		display contained "[a-zA-Z0-9:]*::[^:]*():.*" contains=MEScClass,MEScFunc,MEScNIRate,MEScTextHexNumber,MEScTextNumber
syn match		MEScClass			display contained "[a-zA-Z0-9:]*::" nextgroup=MEScFunc
syn match		MEScFunc			display contained "[^:]*():"he=e-1
syn match		MEScStarted			display contained "MESc GUI[\ \.0-9]* started\..*"
"syn match		MEScStarted			display contained "$(g:MEScStarted_pattern)"
syn match		MEScSettings		display contained "using settings from:.*"
syn match		MEScIni     		display contained "[Rr]eading configuration from .*"
syn match		MEScNIRate     		display contained "NI card started at rate .*"
syn match		MEScFinished		display contained "MESc Qt GUI exited.*"
syn match		MEScMeasStarted		display contained "sigMeasureRunning()"
syn match		MEScMeasStarted2	display contained "sigTestPatternRunning()"
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
    set nowrapscan

    if a:0 > 0
        if a:1 == "b"
            silent! execute "normal ?" . g:MEScStarted_pattern . ""
            call histdel("search", -1)
        endif
    else 
        silent! execute "normal /" . g:MEScStarted_pattern . ""
        call histdel("search", -1)
    endif

    set wrapscan
endfunction

function! SearchMeasurementStart(...)
    set nowrapscan

    if a:0 > 0
        if a:1 == "b"
            silent! execute "normal ?" . g:MeasStarted_pattern . ""
            call histdel("search", -1)
        endif
    else 
        silent! execute "normal /" . g:MeasStarted_pattern . ""
        call histdel("search", -1)
    endif

    set wrapscan
endfunction

function! SearchMeasurementStartInThisMESc(...)
    set nowrapscan

    let a:orig_pos_list = getpos('.')
    let window_first_line_number = line('w0')
    let window_last_line_number = line('w$')

    if a:0 > 0
        if a:1 == "b"
            silent! execute "normal ?" . g:MEScStarted_pattern . ""
            let a:mesc_start_line_number = line('.')
            call histdel("search", -1)

            call cursor(a:orig_pos_list[1], a:orig_pos_list[2])

            silent! execute "normal ?" . g:MeasStarted_pattern . ""
            let a:meas_start_pos_list = getpos('.')
            call histdel("search", -1)

            execute "normal ".window_last_line_number."G"
            execute "normal zb"

            if a:mesc_start_line_number < a:meas_start_pos_list[1]
                call cursor(a:meas_start_pos_list[1], a:meas_start_pos_list[2])
            else
                call cursor(a:orig_pos_list[1], a:orig_pos_list[2])
            endif
        endif
    else 
"        silent! execute "normal /" . g:MeasStarted_pattern . ""
"        call histdel("search", -1)
        silent! execute "normal /" . g:MEScStarted_pattern . ""
        let a:next_mesc_start_line_number = line('.')
        call histdel("search", -1)

        call cursor(a:orig_pos_list[1], a:orig_pos_list[2])

        if a:next_mesc_start_line_number == a:orig_pos_list[1]
            let a:next_mesc_start_line_number = line('$') + 1
        endif

        silent! execute "normal /" . g:MeasStarted_pattern . ""
        let a:next_meas_start_pos_list = getpos('.')
        call histdel("search", -1)

        execute "normal ".window_last_line_number."G"
        execute "normal zb"

        if a:next_mesc_start_line_number > a:next_meas_start_pos_list[1]
            call cursor(a:next_meas_start_pos_list[1], a:next_meas_start_pos_list[2])
        else
            call cursor(a:orig_pos_list[1], a:orig_pos_list[2])
        endif
    endif

    set wrapscan
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
            call histdel("search", -1)
        endif
    else
        let this_line = getline(current_line_number)
        let this_day = strpart(this_line, 1, 10)

        normal G

        execute "normal ?" . this_day . "?+1"
        call histdel("search", -1)
    endif
endfunction

map <F9> :call SearchMEScStart("b")
map <S-F9> :call SearchMEScStart()
map <F10> :call SearchMeasurementStartInThisMESc("b")
map <S-F10> :call SearchMeasurementStartInThisMESc()
map <C-A-F9> :call SearchStartOfDay("b")
map <C-S-A-F9> :call SearchStartOfDay()

"set mouse=n
"set foldmethod=marker
"set foldmarker=MESc\ GUI\ started.,MESc\ Qt\ GUI\ exited
"set foldmethod=expr
set foldexpr=MEScFoldLevel(v:lnum)
set foldcolumn=4
set foldlevel=10

execute "normal G"
call SearchStartOfDay("b")
let g:lnum_last_day_start = line('.')
"execute "normal ".g:orig_window_last_line_number."G"
"execute "normal zb"
call cursor(g:orig_pos_list[1], g:orig_pos_list[2])

function! MEScFoldLevel(lnum)
    let current_line = getline(a:lnum)

    if a:lnum < g:lnum_last_day_start
        return g:mesc_fold_level
    endif

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

"color elflord
" orange background for hlSearch:
"hi Search guibg=#ffaa33 guifg=black
" ping background for hlSearch:
"hi Search guibg=#ff66ff guifg=black
" green/cyan background for hlSearch:
hi Search guibg=#00ffdd guifg=black
hi Normal guifg=lightgray

"set background=dark

set cursorline
hi CursorLine									gui=underline				guibg=NONE

hi LogTime				ctermfg=Gray			guifg=#aaaaaa

hi LogTrace				ctermfg=Black			guifg=#aaaaaa
hi LogDebug				ctermfg=Black			guifg=#555555
hi LogInfo				ctermfg=Black			guifg=#ffffff
hi LogTitle				ctermfg=Green			guifg=#11aa11
hi LogWarning			ctermfg=Yellow			guifg=#eeaa00
hi LogError				ctermfg=Red				guifg=#ff0000
hi LogFatal				ctermfg=Red				guifg=#880000

hi MEScProject			ctermfg=Brown			guifg=#003080

hi MEScClass			ctermfg=Brown			guifg=#0055cc
hi MEScFunc				ctermfg=Brown			guifg=#1a90ff

hi MEScStarted									guifg=#000000				guibg=#ffff00
hi MEScSettings									guifg=#000000				guibg=#999900
hi MEScIni     									guifg=#000000				guibg=#999900
hi MEScNIRate  									guifg=#000000				guibg=#999900
hi MEScFinished									guifg=#000000				guibg=#665500
hi MEScMeasStarted								guifg=#000000				guibg=#00ff00
hi MEScMeasStarted2								guifg=#000000				guibg=#00ff00
hi MEScMeasFinished								guifg=#000000				guibg=#008800
hi MEScTextHexNumber							guifg=#ff00ff
hi MEScTextNumber								guifg=#ff00ff
hi FoldColumn                                   guifg=cyan                  guibg=black
hi Folded                                       guifg=cyan                  guibg=darkgrey
hi Visual                                                                   guibg=#777777
