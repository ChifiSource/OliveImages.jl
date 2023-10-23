module OliveImages
using Olive
using Images
using ImageIO
using FileIO
using Olive.Toolips
using Olive.ToolipsSession
using Olive.ToolipsDefaults
using Olive.ToolipsBase64
using Olive: getname, Project, Directory, Cell
import Olive: build, olive_read

function build(c::Connection, cell::Cell{:svg}, d::Directory{<:Any})
    base = Olive.build_base_cell(c, cell, d)
    style!(base, "background-color" => "red")
    base::Component{:div}
end

function olive_read(cell::Cell{:svg})
    src = read(cell.outputs, String)
    Vector{Cell{<:Any}}([Cell(1, "vimage", src)])::Vector{Cell{<:Any}}
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:vimage}, proj::Project{<:Any})
    newdiv = div("cellcontainer$(cell.id)")
    style!(newdiv, "padding" => 20px, "border-radius" => 0px)
    newdiv[:text] = cell.source
    newdiv::Component{:div}
end

function build(c::Connection, cell::Cell{:png}, d::Directory{<:Any})
    base = Olive.build_base_cell(c, cell, d)
    style!(base, "background-color" => "darkorange")
    base::Component{:div}
end

function olive_read(cell::Cell{:png})
    img = img_obj = load(cell.outputs)
    Vector{Cell{<:Any}}([Cell(1, "image", "png", img)])::Vector{Cell{<:Any}}
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:image}, proj::Project{<:Any})
    newdiv = div("cellcontainer$(cell.id)")
    style!(newdiv, "padding" => 20px, "border-radius" => 0px)
    img = base64img("cell$(cell.id)", cell.outputs, cell.source)
    push!(newdiv, img)
    newdiv::Component{:div}
end

function build(c::Connection, cell::Cell{:gif}, d::Directory{<:Any})
    base = Olive.build_base_cell(c, cell, d)
    style!(base, "background-color" => "darkorange")
    base::Component{:div}
end

function olive_read(cell::Cell{:gif})
    img = img_obj = load(cell.outputs)
    Vector{Cell{<:Any}}([Cell(1, "image", "gif", img)])::Vector{Cell{<:Any}}
end

function build(c::Connection, cell::Cell{:jpg}, d::Directory{<:Any})
    base = Olive.build_base_cell(c, cell, d)
    style!(base, "background-color" => "darkorange")
    base::Component{:div}
end

function olive_read(cell::Cell{:jpg})
    img = img_obj = load(cell.outputs)
    Vector{Cell{<:Any}}([Cell(1, "image", "jpg", img)])::Vector{Cell{<:Any}}
end

end # module OliveImages
