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

function build(c::Connection, cell::Cell{:svg}, d::Directory{<:Any})
    base = Olive.build_base_cell(c, cell, d)
    style!(base, "background-color" => "red")
    base::Component{:div}
end

function olive_read(cell::Cell{:svg})
    src = read(cell.outputs, String)
    Vector{Cell{<:Any}}([Cell{:vimage}(src)])::Vector{Cell{<:Any}}
end

function build(c::Connection, cell::Cell{:png}, d::Directory{<:Any})
    base = Olive.build_base_cell(c, cell, d)
    style!(base, "background-color" => "darkorange")
    base::Component{:div}
end

function olive_read(cell::Cell{:png})
    img = img_obj = load(cell.outputs)
    Vector{Cell{<:Any}}([Cell{:image}("png", img)])::Vector{Cell{<:Any}}
end


function build(c::Connection, cell::Cell{:gif}, d::Directory{<:Any})
    base = Olive.build_base_cell(c, cell, d)
    style!(base, "background-color" => "darkorange")
    base::Component{:div}
end

function olive_read(cell::Cell{:gif})
    img = load(cell.outputs)
    Vector{Cell{<:Any}}([Cell{:image}(cell.source, img)])::Vector{Cell{<:Any}}
end

function build(c::Connection, cell::Cell{:jpg}, d::Directory{<:Any})
    base = Olive.build_base_cell(c, cell, d)
    style!(base, "background-color" => "darkorange")
    base::Component{:div}
end

function olive_read(cell::Cell{:jpg})
    img = load(cell.outputs)
    Vector{Cell{<:Any}}([Cell{:image}(cell.source, "jpg", img)])::Vector{Cell{<:Any}}
end


function build(c::Connection, cm::ComponentModifier, cell::Cell{:vimage}, proj::Project{<:Any})
    newdiv = div("cellcontainer$(cell.id)")
    on(c, newdiv, "dblclick") do cm::ComponentModifier
        alert!(cm, "editing mode not yet available")
    end
    style!(newdiv, "padding" => 20px, "border-radius" => 0px)
    newdiv[:text] = cell.source
    newdiv::Component{:div}
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:image}, proj::Project{<:Any})
    newdiv = div("cellcontainer$(cell.id)")
    style!(newdiv, "padding" => 20px, "border-radius" => 0px)
    img = base64img("cell$(cell.id)", cell.outputs)
    on(c, newdiv, "dblclick") do cm::ComponentModifier
        if "imgbar$(cell.id)" in cm
            remove!(cm, "imgbar$(cell.id)")
            return
        end
        newbar = build_image_bar(c, cm, cell)
        insert!(cm, "cellcontainer$(cell.id)", 1, newbar)
    end
    push!(newdiv, img)
    newdiv::Component{:div}
end

build_image_cell_button(oe::Type{OliveExtension{:change}}, c::AbstractConnection, cell::Cell{<:Any}) = begin
    icon = Olive.topbar_icon("openimg$(cell.id)", "file_open")
    style!(icon, "font-size" => 13pt, "color" => "white")
    icon
end


build_vimage_cell_button(oe::Type{OliveExtension{:change}}, c::AbstractConnection, cell::Cell{<:Any}) = begin
    a(text = "hello")
end


function build_image_bar(c::AbstractConnection, cm::Components.AbstractComponentModifier, cell::Cell{:vimage})
    buttons = Vector{AbstractComponent}([begin 
        ext = m.sig.parameters[2]
        build_image_cell_button(ext, c, cell)
    end for m in methods(build_vimage_cell_button)])
    bar = div("imgbar$(cell.id)", children = buttons)
end

function build_image_bar(c::AbstractConnection, cm::Components.AbstractComponentModifier, cell::Cell{:image})
    buttons = Vector{AbstractComponent}([begin 
        ext = m.sig.parameters[2].parameters[1]
        build_image_cell_button(ext, c, cell)
    end for m in methods(build_image_cell_button)])

    bar = div("imgbar$(cell.id)", children = buttons)
    style!(bar, "padding" => .5percent, "border-bottom-left-radius" => 0px, "border-bottom-left-radius" => 0px, "background-color" => "#1e1e1e", "border-radius" => 2px, 
    "border-bottom" => "black")
    bar::Component{:div}
end

end # module OliveImages
