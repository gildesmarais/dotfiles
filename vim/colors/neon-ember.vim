" neon-ember: mirrors the Ghostty theme of the same name.
" cterm uses the terminal's ANSI slots (0-15) so it tracks the palette;
" 208 is the #ff8800 accent, which has no ANSI slot.
hi clear
if exists('syntax_on') | syntax reset | endif
set background=dark
let g:colors_name = 'neon-ember'

let s:gui = {
  \ 0: '#241e1a', 1: '#ff817a', 2: '#71c45e', 3: '#d1a601',
  \ 4: '#70affe', 5: '#ed80cc', 6: '#0ac4c5', 7: '#d3c8c1',
  \ 8: '#72665e', 9: '#feb5ae', 10: '#9ae08a', 11: '#edc656',
  \ 12: '#a8ceff', 13: '#feace3', 14: '#2fe6e6', 15: '#f7f0eb',
  \ 208: '#ff8800', 'NONE': 'NONE' }

function! s:hi(group, fg, bg, attr) abort
  execute 'hi' a:group
    \ 'ctermfg=' . a:fg 'ctermbg=' . a:bg 'cterm=' . a:attr
    \ 'guifg=' . s:gui[a:fg] 'guibg=' . s:gui[a:bg] 'gui=' . a:attr
endfunction

" Normal follows the terminal's own fg/bg; gui needs them spelled out.
hi Normal ctermfg=NONE ctermbg=NONE guifg=#ff9c4d guibg=#0e0c0a

" Syntax
call s:hi('Comment',      8,   'NONE', 'italic')
call s:hi('Constant',     5,   'NONE', 'NONE')
call s:hi('String',       2,   'NONE', 'NONE')
call s:hi('Character',    2,   'NONE', 'NONE')
call s:hi('Identifier',   6,   'NONE', 'NONE')
call s:hi('Function',     4,   'NONE', 'NONE')
call s:hi('Statement',    208, 'NONE', 'bold')
call s:hi('PreProc',      13,  'NONE', 'NONE')
call s:hi('Type',         3,   'NONE', 'NONE')
call s:hi('Special',      14,  'NONE', 'NONE')
call s:hi('Underlined',   12,  'NONE', 'underline')
call s:hi('Todo',         0,   3,      'bold')
call s:hi('Error',        1,   'NONE', 'bold,reverse')

" Editor chrome
call s:hi('CursorLine',   'NONE', 0,   'NONE')
call s:hi('CursorColumn', 'NONE', 0,   'NONE')
call s:hi('ColorColumn',  'NONE', 0,   'NONE')
call s:hi('LineNr',       8,   'NONE', 'NONE')
call s:hi('CursorLineNr', 208, 0,      'bold')
call s:hi('SignColumn',   8,   'NONE', 'NONE')
call s:hi('FoldColumn',   8,   'NONE', 'NONE')
call s:hi('Folded',       8,   0,      'italic')
call s:hi('NonText',      8,   'NONE', 'NONE')
call s:hi('SpecialKey',   8,   'NONE', 'NONE')
call s:hi('VertSplit',    8,   'NONE', 'NONE')
call s:hi('StatusLine',   7,   0,      'NONE')
call s:hi('StatusLineNC', 8,   0,      'NONE')
call s:hi('TabLine',      8,   0,      'NONE')
call s:hi('TabLineFill',  8,   0,      'NONE')
call s:hi('TabLineSel',   208, 'NONE', 'bold')
call s:hi('Pmenu',        7,   0,      'NONE')
call s:hi('PmenuSel',     0,   208,    'bold')
call s:hi('PmenuSbar',    'NONE', 0,   'NONE')
call s:hi('PmenuThumb',   'NONE', 8,   'NONE')
call s:hi('WildMenu',     0,   208,    'bold')
call s:hi('Visual',       0,   208,    'NONE')
call s:hi('Search',       0,   3,      'NONE')
call s:hi('IncSearch',    0,   208,    'bold')
call s:hi('MatchParen',   208, 'NONE', 'bold,underline')
call s:hi('Title',        208, 'NONE', 'bold')
call s:hi('Directory',    4,   'NONE', 'NONE')
call s:hi('ModeMsg',      208, 'NONE', 'bold')
call s:hi('MoreMsg',      2,   'NONE', 'NONE')
call s:hi('Question',     2,   'NONE', 'NONE')
call s:hi('ErrorMsg',     1,   'NONE', 'bold')
call s:hi('WarningMsg',   3,   'NONE', 'NONE')
call s:hi('DiffAdd',      2,   0,      'NONE')
call s:hi('DiffDelete',   1,   0,      'NONE')
call s:hi('DiffChange',   3,   0,      'NONE')
call s:hi('DiffText',     0,   3,      'bold')
call s:hi('SpellBad',     1,   'NONE', 'underline')
call s:hi('SpellCap',     3,   'NONE', 'underline')

hi! link EndOfBuffer NonText
hi! link Whitespace NonText
