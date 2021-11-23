function! myspacevim#before() abort

    " Modificamos el funcionamiento de la tecla ESC
    inoremap <esc> <NOP>
    inoremap jk <esc>

    " Modifica la tecla leader de VIM
    let g:mapleader = "-"

    " Guarda el archivo actual
    nnoremap <leader>w :w<cr> 
   
    " Silencia la busqueda para evitar que se quede pintada la cadena buscada
    noremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

    " Configuracion de split de ventanas
    set splitbelow
    set splitright

    " Configuracion para la sustitucion de caracteres mostrando en una ventana
    " previa los cambios que se realizaran ejemplo: :%s/word/change/gc

    set inccommand=split
    
    " Configuracion autofolding
    set foldmethod=indent
    set foldnestmax=2

    " Muestra una linea que indica que se llego al numero maximo de columnas
    let &colorcolumn = join(range(81,999), ',')

endf

function! myspacevim#after() abort
endf

