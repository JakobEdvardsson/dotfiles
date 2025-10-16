function copy
    if [ "$argv" = "" ]
        fish_clipboard_copy
    else
        printf "$argv" | fish_clipboard_copy
    end
end
