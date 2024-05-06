---------------------------------------------------------------------------------------------------------------------------
--- @function createButton
--- @description Helper function to create a UI button
--- @relativeComponent the component that the button will be placed relative to.
--- If this value is nil then the button will be position relative to the screen.
--- @name name of the button
--- @width the width of the button
--- @height the height of the button
--- @x the x position of the button either relative or absolute depending on if "relativeComponent"
--- is set or not
--- @y the y position of the button either relative or absolute depending on if "relativeComponent"
--- is set or not
--- @imagePath the image path for the button
--- @buttonType A string indicating the button type. The following are valid values:
--- CIRCULAR
--- SQUARE
--- CIRCULAR_TOGGLE
--- SQUARE_TOGGLE
--- @ending the UI button
--------------------------------------------------------------------------------------------------------------------------- 
function createButton(relativeComponent, name, width, height, x, y, imagePath, buttonType)
    local relX, relY, posX, posY
    if relativeComponent then
        relX, relY = relativeComponent:Position()
        posX = relX + x
        posY = relY + y
    else
        posX = x
        posY = y
    end
    
    local btn = nil
    if buttonType == "CIRCULAR" then
        btn = UIComponent(core:get_ui_root():CreateComponent(name, "ui/templates/round_medium_button"));
    elseif buttonType == "SQUARE" then
        btn = UIComponent(core:get_ui_root():CreateComponent(name, "ui/templates/square_medium_button"));
    elseif buttonType == "CIRCULAR_TOGGLE" then
        btn = UIComponent(core:get_ui_root():CreateComponent(name, "ui/templates/round_medium_button_toggle"));
    elseif buttonType == "SQUARE_TOGGLE" then
        btn = UIComponent(core:get_ui_root():CreateComponent(name, "ui/templates/square_medium_button_toggle"));
    else
        btn = UIComponent(core:get_ui_root():CreateComponent(name, "ui/templates/round_medium_button"));
    end
    
    btn:SetCanResizeHeight(true);
    btn:SetCanResizeWidth(true);
    btn:Resize(width, height);
    btn:SetCanResizeHeight(false);
    btn:SetCanResizeWidth(false);
    btn:MoveTo(posX, posY);
    if imagePath then
        btn:SetImagePath(imagePath)
    end
    return btn
end

---------------------------------------------------------------------------------------------------------------------------
--- @function createText
--- @description Helper function to create a text ui
--- @relativeComponent the component that the text will be placed relative to.
--- If this value is nil then the text will be position relative to the screen.
--- @name name of the text
--- @width the width of the text
--- @height the height of the text
--- @x the x position of the text either relative or absolute depending on if "relativeComponent"
--- is set or not
--- @y the y position of the text either relative or absolute depending on if "relativeComponent"
--- is set or not
--- @type A string indicating the text type. The following are valid values:
--- TITLE
--- @ending the UI text
--------------------------------------------------------------------------------------------------------------------------- 
function createText(relativeComponent, name, width, height, x, y, type)
    local relX, relY, posX, posY
    if relativeComponent then
        relX, relY = relativeComponent:Position()
        posX = relX + x
        posY = relY + y
    else
        posX = x
        posY = y
    end
    
    local txt = nil
    if type == "TITLE" then
        txt = UIComponent(core:get_ui_root():CreateComponent(name, "ui/templates/panel_title"));
    else
        txt = UIComponent(core:get_ui_root():CreateComponent(name, "ui/templates/panel_title"));
    end
    
    txt:SetCanResizeHeight(true);
    txt:SetCanResizeWidth(true);
    txt:Resize(width, height);
    txt:SetCanResizeHeight(false);
    txt:SetCanResizeWidth(false);
    txt:MoveTo(posX, posY);
    return txt
end

---------------------------------------------------------------------------------------------------------------------------
--- @function registerForClick
--- @description helper function to register ui click
--- @component the component to register click event
--- @listenerName the name of the event listener
--- @callback the callback function to call when the ui is clicked
--------------------------------------------------------------------------------------------------------------------------- 
function registerForClick(component, listenerName, callback)
    core:add_listener(
        listenerName,
        "ComponentLClickUp",
        function(context)
            --# assume context : CA_UIContext
            return component == UIComponent(context.component);
        end,
        function(context)
            callback(context);
        end,
        true
    );
end