function print_r(player, t)
	local print_r_cache={}
	local function sub_print_r(t,indent)
		if (print_r_cache[tostring(t)]) then
			player.print(indent.."*"..tostring(t))
		else
			print_r_cache[tostring(t)]=true
			if (type(t)=="table") then
				for pos,val in pairs(t) do
					if (type(val)=="table") then
						player.print(indent.."["..tostring(pos).."] => "..tostring(t).." {")
						sub_print_r(val,indent..string.rep(" ",string.len(tostring(pos))+8))
						player.print(indent..string.rep(" ",string.len(tostring(pos))+6).."}")
					elseif (type(val)=="string") then
						player.print(indent.."["..tostring(pos)..'] => "'..val..'"')
					else
						player.print(indent.."["..tostring(pos).."] => "..tostring(val))
					end
				end
			else
				player.print(indent..tostring(t))
			end
		end
	end
	if (type(t)=="table") then
		player.print(tostring(t).." {")
		sub_print_r(t,"  ")
		player.print("}")
	else
		sub_print_r(t,"  ")
	end
end
