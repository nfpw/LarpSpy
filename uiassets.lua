local function adonis_prompt(opts)
	local tween_service = game.GetService(game, "TweenService")
	local http_service = game.GetService(game, "HttpService")
	local rgb = Color3.fromRGB
	local settings, answer = opts.settings, nil
	local accent_c, bg, edge = rgb(120, 200, 255), rgb(15, 16, 21), rgb(40, 44, 56)
	local quiet, quiet_hover, light = rgb(32, 35, 45), rgb(44, 48, 62), rgb(232, 234, 240)
	local regular = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)
	local semibold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)

	local function new(class, props)
		local object = Instance.new(class)

		for key, value in props do
			if key ~= "Parent" then
				object[key] = value
			end
		end

		object.Parent = props.Parent

		return object
	end

	local gui = new("ScreenGui", {
		Name = http_service.GenerateGUID(http_service, false),
		ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 999999,
	})

	opts.parent(gui)

	local function play(object, info, goal)
		local playing = tween_service.Create(tween_service, object, info, goal)

		playing.Play(playing)

		return playing
	end

	local function fade(object, goal, time)
		return play(object, TweenInfo.new(time or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)
	end

	local function on(signal, callback)
		return signal.Connect(signal, callback)
	end

	local function corner(parent, radius)
		new("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius)})
	end

	local function outline(parent, color)
		return new("UIStroke", {Parent = parent, Color = color, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
	end

	local box = new("CanvasGroup", {
		Parent = gui, GroupTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, opts.has_oth and 700 or 600, 0, 132),
		BackgroundColor3 = bg, BorderSizePixel = 0, Active = true,
	})

	corner(box, 10)

	local box_stroke = outline(box, rgb(38, 41, 52))
	local scale = new("UIScale", {Parent = box, Scale = 0.92})
	local bar = new("Frame", {Parent = box, Position = UDim2.new(0, 14, 0, 14), Size = UDim2.new(0, 3, 0, 16), BackgroundColor3 = accent_c, BorderSizePixel = 0})

	corner(bar, 2)

	local function label(props)
		props.Parent, props.BackgroundTransparency, props.TextXAlignment = box, 1, Enum.TextXAlignment.Left

		return new("TextLabel", props)
	end

	label({
		Position = UDim2.new(0, 25, 0, 12), Size = UDim2.new(1, -40, 0, 20), FontFace = semibold, TextSize = 15,
		RichText = true, TextColor3 = light,
		Text = '<font color="#78c8ff">Larp</font> Spy  <font color="#979aa0">Adonis bypass</font>',
	})

	label({
		Position = UDim2.new(0, 14, 0, 40), Size = UDim2.new(1, -28, 0, 34), FontFace = regular, TextSize = 12,
		TextWrapped = true, TextYAlignment = Enum.TextYAlignment.Top, TextColor3 = rgb(151, 153, 160),
		Text = "Load the Adonis bypass before the spy hooks anything? It finishes loading first, so the hooks go in safely.",
	})

	local row = new("Frame", {Parent = box, BackgroundTransparency = 1, Position = UDim2.new(0, 14, 1, -40), Size = UDim2.new(1, -28, 0, 26)})

	new("UIListLayout", {Parent = row, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder})

	local function make_button(order, primary)
		local object = new("TextButton", {
			Parent = row, LayoutOrder = order, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = primary and accent_c or quiet, BorderSizePixel = 0, AutoButtonColor = false,
			FontFace = primary and semibold or regular, TextSize = 12, TextColor3 = primary and bg or light,
		})

		new("UIPadding", {Parent = object, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})
		corner(object, 6)

		return object, outline(object, primary and accent_c or edge)
	end

	for index, choice in {{"don't ask again", "never", false}, {"skip", "skip", false}, {"load", "load", true}} do
		local object, border = make_button(index, choice[3])
		local fill = choice[3] and accent_c or quiet
		local over = choice[3] and accent_c.Lerp(accent_c, rgb(255, 255, 255), 0.25) or quiet_hover

		object.Text = choice[1]

		on(object.MouseEnter, function()
			if answer then return end
			fade(object, {BackgroundColor3 = over})
			if not choice[3] then fade(border, {Color = accent_c.Lerp(accent_c, edge, 0.5)}) end
		end)

		on(object.MouseLeave, function()
			if answer then return end
			fade(object, {BackgroundColor3 = fill})
			if not choice[3] then fade(border, {Color = edge}) end
		end)

		on(object.MouseButton1Click, function()
			answer = answer or choice[2]
		end)
	end

	local redraw_oth = function() end

	if opts.reset then
		local reset_button = make_button(-1, false)

		reset_button.Text = "reset config"
		on(reset_button.MouseEnter, function() fade(reset_button, {BackgroundColor3 = quiet_hover}) end)
		on(reset_button.MouseLeave, function() fade(reset_button, {BackgroundColor3 = quiet}) end)
		on(reset_button.MouseButton1Click, function()
			pcall(opts.reset)
			redraw_oth()
			reset_button.Text = "config reset!"
			task.delay(1.5, function()
				if reset_button.Parent then reset_button.Text = "reset config" end
			end)
		end)
	end

	if opts.has_oth then
		local toggle, toggle_border = make_button(0, false)

		local function draw()
			local enabled = settings.UseOthHook == true

			toggle.Text = "oth.hook: " .. (enabled and "on" or "off")
			toggle.TextColor3 = enabled and accent_c or light
			toggle_border.Color = enabled and accent_c or edge
		end

		draw()
		redraw_oth = draw

		on(toggle.MouseEnter, function() fade(toggle, {BackgroundColor3 = quiet_hover}) end)
		on(toggle.MouseLeave, function() fade(toggle, {BackgroundColor3 = quiet}) end)
		on(toggle.MouseButton1Click, function()
			settings.UseOthHook = not settings.UseOthHook
			draw()
			opts.save()
		end)
	end

	do
		local low, low_border = make_button(0, false)

		local function draw_low()
			local enabled = settings.LowLevelExec == true

			low.Text = "low level exec: " .. (enabled and "on" or "off")
			low.TextColor3 = enabled and accent_c or light
			low_border.Color = enabled and accent_c or edge
		end

		draw_low()

		local prev = redraw_oth

		redraw_oth = function() prev() draw_low() end

		on(low.MouseEnter, function() fade(low, {BackgroundColor3 = quiet_hover}) end)
		on(low.MouseLeave, function() fade(low, {BackgroundColor3 = quiet}) end)
		on(low.MouseButton1Click, function()
			settings.LowLevelExec = not settings.LowLevelExec
			draw_low()
			opts.save()
		end)
	end

	play(scale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
	fade(box, {GroupTransparency = 0}, 0.25)

	while not answer and gui.Parent do
		task.wait()
	end

	local closing = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local fade_out = play(box, closing, {GroupTransparency = 1})

	play(scale, closing, {Scale = 0.96})
	play(box, closing, {Position = UDim2.new(0.5, 0, 0.5, 8)})
	play(box_stroke, closing, {Transparency = 1})

	if gui.Parent then
		fade_out.Completed.Wait(fade_out.Completed)
	end

	gui.Destroy(gui)
	task.wait(0.15)

	return answer
end

local function build(ctx)
	local t, ui, connect, tween_service, accented = ctx.t, ctx.ui, ctx.connect, ctx.tween_service, ctx.accented
	local lib = {}
	local rgb = Color3.fromRGB

	ui.duals, ui.classic_only, ui.titles, ui.check_rows = {}, {}, {}, {}

	local function apply(object, props)
		for key, value in props do
			if key ~= "Parent" then
				object[key] = value
			end
		end

		return object
	end

	local function new(class, props)
		local object = Instance.new(class)

		if props.BorderColor3 ~= nil and props.BorderSizePixel ~= nil then
			object.SetAttribute(object, "Bd", true)
		end

		apply(object, props).Parent = props.Parent

		return object
	end

	local function accent(object, property)
		table.insert(accented, {object, property})
		object[property] = t.Accent

		return object
	end

	local function round(parent, radius)
		local corner = parent.FindFirstChildOfClass(parent, "UICorner") or Instance.new("UICorner")

		corner.SetAttribute(corner, "R", radius or 6)
		corner.CornerRadius = UDim.new(0, ui.classic and 0 or (radius or 6))
		corner.Parent = parent

		return corner
	end

	local function stroke(parent, color)
		if parent.IsA(parent, "GuiObject") then
			round(parent)
		end

		return new("UIStroke", {Parent = parent, Color = color or t.Outline, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, LineJoinMode = ui.classic and Enum.LineJoinMode.Miter or Enum.LineJoinMode.Round})
	end

	local function tween(object, goal, time)
		local playing = tween_service.Create(tween_service, object, TweenInfo.new(time or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), goal)

		playing.Play(playing)

		return playing
	end

	local function smooth(object, goal, time)
		local playing = tween_service.Create(tween_service, object, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), goal)

		playing.Play(playing)

		return playing
	end

	local function text(parent, props, class)
		local font_face, font_size, pixel = ctx.font()

		local label = new(class or "TextLabel", apply({
			Parent = parent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = font_face,
			TextSize = font_size,
			TextColor3 = t.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Text = "",
			AutoButtonColor = class == "TextButton" and false or nil,
		}, props))

		if pixel then
			new("UIStroke", {Parent = label, Name = "TxtOutline", Color = rgb(0, 0, 0), Transparency = 0.6, Thickness = 1, LineJoinMode = Enum.LineJoinMode.Miter})
		end

		return label
	end

	local function dual(object, classic_key, modern_key)
		object.Color = t[ui.classic and classic_key or modern_key]
		table.insert(ui.duals, {object, classic_key, modern_key})

		return object
	end

	local function only_classic(object)
		object.Visible = ui.classic == true
		table.insert(ui.classic_only, object)

		return object
	end

	local function glow(parent, height, top)
		local frame = accent(new("Frame", {Parent = parent, Size = UDim2.new(1, 0, 0, height), BorderSizePixel = 0}), "BackgroundColor3")

		new("UIGradient", {Parent = frame, Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, top), NumberSequenceKeypoint.new(0.193, 0.869), NumberSequenceKeypoint.new(0.504, 0.969), NumberSequenceKeypoint.new(1, 1)})})

		return frame
	end

	local function panel(parent, title)
		local classic = ui.classic
		local frame = new("Frame", {Parent = parent, BackgroundColor3 = t.Inline, BorderSizePixel = classic and 2 or 0, BorderColor3 = t.Outline, ClipsDescendants = true})

		dual(stroke(frame), "Border", "Outline")
		only_classic(accent(new("Frame", {Parent = frame, Size = UDim2.new(1, 0, 0, 1), BorderSizePixel = 0, ZIndex = 2}), "BackgroundColor3"))
		only_classic(glow(frame, 15, 0))

		local head = text(frame, {Name = "Title", Position = UDim2.new(0, classic and 7 or 10, 0, classic and 5 or 6), Size = UDim2.new(1, classic and -14 or -20, 0, classic and 12 or 14), Text = title, FontFace = ctx.bold(), TextColor3 = classic and t.Text or t.Accent})

		table.insert(ui.titles, head)

		return frame, head
	end

	local function input(parent, props, placeholder)
		local holder = apply(new("Frame", {Parent = parent, BackgroundColor3 = t.Element, BorderSizePixel = 0}), props)
		local holder_stroke = stroke(holder, t.Outline)
		local box = text(holder, {Position = UDim2.new(0, 6, 0, 0), Size = UDim2.new(1, -12, 1, 0), PlaceholderText = placeholder or "", PlaceholderColor3 = t.Dim, ClearTextOnFocus = false}, "TextBox")
		local hovering, focusing = false, false

		local function paint()
			local color, fill = t.Outline, t.Element

			if focusing then
				color = t.Accent
			elseif hovering then
				color, fill = t.Outline.Lerp(t.Outline, t.Accent, 0.5), t.Element.Lerp(t.Element, t.Hover, 0.5)
			end

			tween(holder_stroke, {Color = color})
			tween(holder, {BackgroundColor3 = fill})
		end

		connect(holder.MouseEnter, function() hovering = true paint() end)
		connect(holder.MouseLeave, function() hovering = false paint() end)
		connect(box.Focused, function() focusing = true paint() end)
		connect(box.FocusLost, function() focusing = false paint() end)

		return box, holder
	end

	local function button(parent, label, props, callback)
		local object = apply(text(parent, {BackgroundTransparency = 0, BackgroundColor3 = t.Element, Text = label, TextXAlignment = Enum.TextXAlignment.Center}, "TextButton"), props)

		stroke(object, t.Outline)

		if object.AutomaticSize == Enum.AutomaticSize.X then
			new("UIPadding", {Parent = object, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
		end

		connect(object.MouseEnter, function() tween(object, {BackgroundColor3 = t.Hover}) end)
		connect(object.MouseLeave, function() tween(object, {BackgroundColor3 = t.Element}) end)

		if callback then
			connect(object.MouseButton1Click, callback)
		end

		return object
	end

	local function horizontal_list(parent, padding)
		return new("UIListLayout", {Parent = parent, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, padding or 5), SortOrder = Enum.SortOrder.LayoutOrder})
	end

	local function esc(value)
		local result = string.gsub(tostring(value), "&", "&amp;")
		result = string.gsub(result, "<", "&lt;")

		return (string.gsub(result, ">", "&gt;"))
	end

	return {
		accent = accent, new = new, round = round, stroke = stroke, dual = dual, only_classic = only_classic,
		text = text, tween = tween, smooth = smooth, esc = esc, glow = glow, panel = panel,
		input = input, button = button, horizontal_list = horizontal_list,
	}
end

return setmetatable({adonis_prompt = adonis_prompt}, {__call = function(_, ctx) return build(ctx) end})
