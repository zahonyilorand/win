" Vim syntax file for femtoCamera log files

let g:camStarted_pattern = "------------ START ------------"
let g:camLiveStarted_pattern = "\<startLive\>"
let g:camLiveFinished_pattern = "\<stopLive\>"
let g:cam_fold_level = "0"

syn match		LogRow				display "^[ \t]*<[ 0-9a-zA-Z\.\:\-]*>[ \t]" contains=LogTime
syn match		LogTime				display contained "^[ \t]*<[ 0-9a-zA-Z\.\:\-]*>" nextgroup=camClassAndFunc
syn match		camClassAndFunc		display contained "[ \t][a-zA-Z0-9:]*(): .*" contains=camClass,camFunc
syn match		camClass			display contained "[a-zA-Z0-9:]*::"
syn match		camFunc				display contained "[a-zA-Z0-9]*():"he=e-1 nextgroup=camText
syn match		camText		    	display contained " .*" contains=camTextHexNumber,camTextNumber,camStarted,camSVNVersion,camFinished,camOpen,camLiveStarted,camLiveFinished
syn match		camStarted			display contained "------------ START ------------"
"syn match		camStarted			display contained "$(g:camStarted_pattern)"
syn match		camSVNVersion		display contained "SVN revision: .*"
syn match		camOpen				display contained " serial number: .*"hs=s+1 contains=camFunc
syn match		camFinished			display contained "------------ END ------------"
syn match		camLiveStarted		display contained "\<startLive\>"
syn match		camLiveFinished		display contained "\<stopLive\>"
syn match		camTextHexNumber  	display contained "\<0[xX][0-9a-fA-F]\+\>"
syn match		camTextNumber  		display contained "[-]\?[0-9]\.[0-9]\+[eE][+-][0-9]\+\|[-]\?\<[0-9][\.0-9]*\>"

"command! -nargs=0 MakeRCTraceFolding :call MakeRCTraceFoldingFunc()
"function! MakeRCTraceFoldingFunc()
"  syn region      TrcEntryExit start=/^[ \t]*[0-9\.\:\-]*[ \t]ENTRY[ \t]/ end=/^[ \t]*[0-9\.\:\-]*[ \t]EXIT[ \t]/ contains=TrcEntryExit,camClass,LogRowStart,TrcFilePos fold
"  "syn sync fromstart
"  "syn sync maxlines=100
"  set foldlevel=8
"  set foldmethod=syntax
"  set foldcolumn=6
"endfunction

function! SearchCameraStart(...)
    if a:0 > 0
        if a:1 == "b"
            execute "normal ?" . g:camStarted_pattern . ""
            call histdel("search", -1)
        endif
    else 
        execute "normal /" . g:camStarted_pattern . ""
        call histdel("search", -1)
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

map <F9> :call SearchCameraStart("b")
map <F10> :call SearchCameraStart()
map <C-F9> :call SearchStartOfDay("b")
map <C-F10> :call SearchStartOfDay()

"set mouse=n
"set foldmethod=marker
"set foldmarker=MESc\ GUI\ started.,MESc\ Qt\ GUI\ exited
"set foldmethod=expr
set foldexpr=CameraFoldLevel(v:lnum)
set foldcolumn=4
"set foldlevel=1000

function! CameraFoldLevel(lnum)
    let current_line = getline(a:lnum)
    let next_line = getline(a:lnum + 1)

    if current_line =~ g:camStarted_pattern
        let g:cam_fold_level = ">1"
    elseif g:cam_fold_level != "0"
        if next_line =~ g:camStarted_pattern
            let g:cam_fold_level = "<1"
        else
            if current_line =~ g:camLiveStarted_pattern
                let g:cam_fold_level = "a1"
            elseif current_line =~ g:camLiveFinished_pattern
                let g:cam_fold_level = "s1"
            else
                let g:cam_fold_level = "="
            endif
        endif
    endif

    return g:cam_fold_level
endfunction

let b:current_syntax = "femtocameralog"

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

hi LogTime				ctermfg=Gray			guifg=#aaaaaa

hi camClass				ctermfg=Brown			guifg=#0055cc
hi camFunc				ctermfg=Brown			guifg=#1a90ff

hi camStarted									guifg=#000000				guibg=#ffff00
hi camSVNVersion								guifg=#000000				guibg=#ffff00
hi camOpen										guifg=#000000				guibg=#ffff00
hi camFinished									guifg=#000000				guibg=#aaaa00
hi camLiveStarted								guifg=#000000				guibg=#00ff00
hi camLiveFinished								guifg=#000000				guibg=#008800
hi camTextHexNumber								guifg=#ff00ff
hi camTextNumber								guifg=#ff00ff
hi FoldColumn                                   guifg=cyan                  guibg=black
hi Folded                                       guifg=cyan                  guibg=darkgrey
hi Visual                                                                   guibg=#777777
