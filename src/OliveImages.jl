module OliveImages
using Olive
using Images
using Olive.Toolips
using Olive.ToolipsSession
using Olive.ToolipsDefaults
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
    style!(newdiv, "padding" => 12px, "border-radius" => 0px)
    newdiv[:text] = cell.source
    newdiv::Component{:div}
end

function build(c::Connection, cell::Cell{:png}, d::Directory{<:Any})
    base = Olive.build_base_cell(c, cell, d)
    style!(base, "background-color" => "darkorange")
    base::Component{:div}
end

function olive_read(cell::Cell{:png})
    img = Images.read(cell.outputs)
    Vector{Cell{<:Any}}([Cell(1, "image", "png", img)])::Vector{Cell{<:Any}}
end

function build(c::Connection, cm::ComponentModifier, cell::Cell{:image}, proj::Project{<:Any})
    newdiv = div("cellcontainer$(cell.id)")
    style!(newdiv, "padding" => 12px, "border-radius" => 0px)
    newdiv[:text] = cell.source
    newdiv::Component{:div}
end

end # module OliveImages
