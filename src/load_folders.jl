function read_addresses(main_address = "src")
    if main_address == "src//load_folders.jl"
        return nothing
    elseif isfile(main_address)
        address_ignoring_src = main_address[6:end]
        include(address_ignoring_src)
    elseif isdir(main_address)
        sub_address_list = cd(readdir, main_address)
        for sub_address_name in sub_address_list
            sub_address_address = "$(main_address)//$(sub_address_name)"
            read_address(sub_address_address)
        end
    else
        @error("Something got wrong in $(main_address). \nIt isn't a file and isn't a folder, but somehow it was in the list to load by using:\n cd(readdir, address)")
    end
    return nothing
end

read_addresses()