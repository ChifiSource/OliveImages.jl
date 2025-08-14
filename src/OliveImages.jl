module OliveImages
using Olive
using Images
using ImageIO
using FileIO
using Olive.Toolips
using Olive.Toolips.Components
using Olive.ToolipsSession
using Olive: getname, Project, Directory, Cell
import Olive: build, olive_read, OliveExtension

#== file cells
==#

function build(c::Connection, cell::Cell{:svg}, d::Directory{<:Any})
    base = Olive.build_base_cell(c, cell, d)
    style!(base, "background-color" => "#a32921")
    base::Component{:div}
end

function olive_read(cell::Cell{:svg})
    src = read(cell.outputs, String)
    Vector{Cell{<:Any}}([Cell{:vimage}(src)])::Vector{Cell{<:Any}}
end

function build(c::Connection, cell::Cell{:png}, d::Directory{<:Any})
    base = Olive.build_base_cell(c, cell, d)
    style!(base, "background-color" => "#15214d")
    base::Component{:div}
end

function olive_read(cell::Cell{:png})
    img = load(cell.outputs)
    Vector{Cell{<:Any}}([Cell{:image}("PNG", cell.source => img)])::Vector{Cell{<:Any}}
end


function build(c::Connection, cell::Cell{:gif}, d::Directory{<:Any})
    base = Olive.build_base_cell(c, cell, d)
    style!(base, "background-color" => "#15214d")
    base::Component{:div}
end

function olive_read(cell::Cell{:gif})
    img = load(cell.outputs)
    Vector{Cell{<:Any}}([Cell{:image}("GIF", cell.source => img)])::Vector{Cell{<:Any}}
end

function build(c::Connection, cell::Cell{:jpg}, d::Directory{<:Any})
    base = Olive.build_base_cell(c, cell, d)
    style!(base, "background-color" => "#15214d")
    base::Component{:div}
end

function olive_read(cell::Cell{:jpg})
    img = load(cell.outputs)
    Vector{Cell{<:Any}}([Cell{:image}("JPG", cell.source => img)])::Vector{Cell{<:Any}}
end

function base64_to_image(b64str, fmt::String = "PNG")
    data = Components.base64decode(b64str)
    io = IOBuffer(data)
    return load(Stream{DataFormat{Symbol(fmt)}}(io))
end

function image_to_base64(img, fmt::String = "PNG")
    io = IOBuffer()
    save(Stream{DataFormat{Symbol(fmt)}}(io), img) # save in memory stream
    seekstart(io)
    return Components.base64encode(take!(io))
end

#== session cells
==#

function build(c::Connection, cm::ComponentModifier, cell::Cell{:vimage}, proj::Project{<:Any})
    newdiv = div("cellcontainer$(cell.id)")
    on(c, newdiv, "dblclick") do cm::ComponentModifier
        alert!(cm, "editing mode not yet available")
    end
    style!(newdiv, "padding" => 20px, "border-radius" => 0px)
    newdiv[:text] = cell.source
    newdiv::Component{:div}
end

# base64_to_image(replace(img[:src], "data:image/png;base64," => ""))

function build(c::Connection, cm::ComponentModifier, cell::Cell{:image}, proj::Project{<:Any})
    newdiv = div("cellcontainer$(cell.id)")
    style!(newdiv, "padding" => 20px, "border-radius" => 0px)
    if typeof(cell.outputs) <: AbstractString
        if cell.outputs == ""
            push!(newdiv, build_image_bar(c, cm, cell, proj))
            return(newdiv)
        end
        outp_splits = split(cell.outputs, "!|")
        cell.outputs = string(outp_splits[1]) => base64_to_image(outp_splits[2])
        cell.source = replace(cell.source, "# " => "")
    end
    img = base64img("cell$(cell.id)", cell.outputs[2], lowercase(cell.source))
    on(c, newdiv, "dblclick") do cm::ComponentModifier
        if "imgbar$(cell.id)" in cm
            remove!(cm, "imgbar$(cell.id)")
            return
        end
        newbar = build_image_bar(c, cm, cell, proj)
        insert!(cm, "cellcontainer$(cell.id)", 1, newbar)
    end
    push!(newdiv, img)
    newdiv::Component{:div}
end

function buildbase_imgcell_button(name::AbstractString, cellid::String, icon::String)
    icon = Olive.topbar_icon("$name$cellid", icon)
    style!(icon, "font-size" => 16pt, "color" => "white")
    icon::Component{:span}
end

function build_fileseeker()

end

build_image_cell_button(oe::Type{OliveExtension{:change}}, c::AbstractConnection, cell::Cell{<:Any}, proj::Olive.Project) = begin
    cellid::String = cell.id
    icon = buildbase_imgcell_button("openimg", cellid, "file_open")
    on(c, icon, "click") do cm::ComponentModifier
        set_children!(cm, "imgbar$cellid", )
    end
    icon
end

build_image_cell_button(oe::Type{OliveExtension{:resize}}, c::AbstractConnection, cell::Cell{<:Any}, proj::Olive.Project) = begin
    icon = buildbase_imgcell_button("resimg", cell.id, "settings_overscan")
    on(c, icon, "click") do cm::ComponentModifier

    end
    style!(icon, "font-size" => 16pt, "color" => "white")
    icon
end

build_vimage_cell_button(oe::Type{OliveExtension{:change}}, c::AbstractConnection, cell::Cell{<:Any}, proj::Olive.Project) = begin
    icon = Olive.topbar_icon("openimg$(cell.id)", "file_open")
    style!(icon, "font-size" => 16pt, "color" => "white")
    icon
end

function build_imagecellcontrols(c::AbstractConnection, cell::Cell{<:Any}, proj::Olive.Project)
    cellid = cell.id
    icon_s = ("font-size" => 16pt, "color" => "white")
    up_icon = Olive.topbar_icon("upbutton$cellid", "arrow_circle_up")
    down_icon = Olive.topbar_icon("dwnbutton$cellid", "arrow_circle_down")
    del_icon = Olive.topbar_icon("delbutton$cellid", "dangerous")
    style!(up_icon, icon_s ...)
    style!(down_icon, "margin-right" => 10px, icon_s ...)
    style!(del_icon, "font-size" => 16pt, "color" => "red", "margin-right" => 10px)
    on(c, up_icon, "click") do cm::ComponentModifier
        Olive.cell_up!(c, cm, cell, proj)
    end
    on(c, down_icon, "click") do cm::ComponentModifier
        Olive.cell_down!(c, cm, cell, proj)
    end
    on(c, del_icon, "click") do cm::ComponentModifier
        Olive.cell_delete!(c, cm, cell, proj[:cells])
    end
    [del_icon, up_icon, down_icon]
end


function build_image_bar(c::AbstractConnection, cm::Components.AbstractComponentModifier, cell::Cell{:vimage}, proj::Olive.Project)
    buttons = Vector{AbstractComponent}([begin 
        ext = m.sig.parameters[2].parameters[1]
        build_vimage_cell_button(ext, c, cell, proj)
    end for m in methods(build_vimage_cell_button)])
    bar = div("imgbar$(cell.id)", children = buttons)
end

function build_image_bar(c::AbstractConnection, cm::Components.AbstractComponentModifier, cell::Cell{:image}, proj::Olive.Project)
    buttons = Vector{AbstractComponent}([begin 
        ext = m.sig.parameters[2].parameters[1]
        build_image_cell_button(ext, c, cell, proj)
    end for m in methods(build_image_cell_button)])
    controls = build_imagecellcontrols(c, cell, proj)
    label = a(text = cell.outputs[1])
    style!(label, "color" => "#e3d7c5", "margin-right" => 15px)
    bar = div("imgbar$(cell.id)", children = [controls ..., label, buttons ...])
    style!(bar, "padding" => .5percent, "border-bottom-left-radius" => 0px, "border-bottom-left-radius" => 0px, "background-color" => "#1e1e1e", "border-radius" => 2px, 
    "border-bottom" => "black")
    bar::Component{:div}
end

string(cell::Cell{:image}) = begin

end

string(cell::Cell{:vimage}) = begin

end

end # module OliveImages
