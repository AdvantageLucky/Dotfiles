function fish_greeting
    set_color --italics 8A7156
    echo -e 'Hello, microbread\nDate: '(date '+%A %d %b, %H:%M')
    set_color normal
end
