Atlas = {}
 
Atlas.ControlCallbacks = {
        ["DFrame"] = function(obj, args)
                obj:SetTitle(args[1])
                obj:SetVisible(args[2])
                obj:SetDraggable(args[3])
                obj:ShowCloseButton(args[4])
				obj:MakePopup()
        end,
        ["DPanel"] = function(obj, args)
                obj:SetBackgroundColor(args[1])
        end,
        ["DLabel"] = function(obj, args)
                obj:SetText(args[1])
                obj:SetFont(args[2])
                obj:SetColor(args[3])
                --obj:SizeToContents()
        end,
        ["DButton"] = function(obj, args)
                obj:SetText(args[1])
                obj:SetImage(args[2])
        end,
        ["DCheckBoxLabel"] = function(obj, args)
                obj:SetText(args[1])
                obj:SetChecked(args[2])
                obj:SetConVar(args[3])
                obj:SetValue(args[4])
                obj:SizeToContents()
        end,
        ["DNotify"] = function(obj, args)
                obj:SetLife(args[1])
        end,
        ["DNumberWang"] = function(obj, args)
                obj:SetValue(args[1])
                obj:SetMin(args[2])
                obj:SetMax(args[3])
        end,
        ["DNumSlider"] = function(obj, args)
                obj:SetText(args[1])
                obj:SetValue(args[2])
                obj:SetMin(args[3])
                obj:SetMax(args[4])
                obj:SetDecimals(args[5])
                obj:SetConVar(args[6])
        end,
        ["DPropertySheet"] = function(obj, args)
                obj:SetActiveTab(args[1])
        end,
        ["DGrid"] = function(obj, args)
                obj:SetCols(args[1])
                obj:SetColWide(args[2])
        end,
        ["DImage"] = function(obj, args)
                obj:SetImage(args[1])
                --obj:SizeToContents()
        end,
        ["DImageButton"] = function(obj, args)
                obj:SetImage(args[1])
        end,
        ["DListView"] = function(obj, args)
                obj:SetMultiSelect(args[1])
        end,
        ["DTextEntry"] = function(obj, args)
                obj:SetText(args[1])
                obj:SetMultiline(args[2])
                obj:SetEditable(args[3])
        end,
        ["DCollapsibleCategory"] = function(obj, args)
                obj:SetLabel(args[1])
                obj:SetExpanded(args[2])
        end,
        ["DPanelList"] = function(obj, args)
                obj:SetSpacing(args[1])
                obj:EnableVerticalScrollbar(args[2])
                obj:EnableHorizontal(args[3])
                obj:SetPadding(args[4])
                obj:SizeToContents()
        end,
        ["DForm"] = function(obj, args)
                obj:SetName(args[1])
                obj:SetSpacing(args[2])
        end,
        ["DProgress"] = function(obj, args)
                obj:SetFraction(args[1])
        end,
        ["DComboBox"] = function(obj, args)
               -- obj:SetEditable(args[1])
        end,
        ["DPanelList"] = function(obj, args)
                obj:SetSpacing(args[1])
                obj:EnableHorizontal(args[2])
                obj:EnableVerticalScrollbar(args[3])
        end,
        ["DCategoryList"] = function(obj, args)

        end,
        ["DPropertySheet"] = function(obj, args)
            obj:AddSheet(args[1], args[2], args[3], false, false, args[4])
        end,
        ["DForm"] = function(obj, args)
            obj:SetSpacing( args[1] )
        end,
        ["DImageButton"] = function(obj, args)
            obj:SetImage( args[1] )
        end
        
}

function Atlas:Create( control, parent, x, y, w, h, ... )
        local obj = vgui.Create( control, parent )
       
        --[[ These will never change between objects. ]]--
                obj:SetPos( x, y )
                obj:SetSize( w, h )
       
        if ( self.ControlCallbacks[control] ) then
                local args = {...}
                self.ControlCallbacks[control]( obj, args )
        end
		
        return obj
end

function Atlas:CreateCatList(name, parent, items, contents)
        local obj = vgui.Create( "DCollapsibleCategory", parent )
        obj:SetLabel( name )
        obj:SetExpanded( 1 )
       
        obj.Contents = vgui.Create( "DListView", obj )
        obj.Contents:SetPos(0, 20)
        obj.Contents:SetSize(175, 100)
        for k,v in ipairs(items) do
            obj.Contents:AddLine(v) -- Add lines
        end
        obj.Contents:SetMultiSelect(false)

        parent:AddItem( obj )
 
        --[[ Call the function. ]]--
     --   contents( obj )
       
        return obj
end